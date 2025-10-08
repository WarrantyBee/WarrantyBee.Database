<#
.SYNOPSIS
    Runs the WarrantyBee database migrations in the correct order.
.DESCRIPTION
    This script orchestrates the execution of SQL scripts to set up the WarrantyBee database.
    It reads dependencies from `dependencies.json` to run master scripts in the correct order,
    then creates and populates the application tables.

    The script requires the MySQL .NET Connector (MySql.Data.dll) to be available.
    You can install it via PowerShell:
    Install-Package MySql.Data -ProviderName NuGet

.PARAMETER Server
    The hostname or IP address of the MySQL server.
.PARAMETER Port
    The port number for the MySQL server.
.PARAMETER Database
    The name of the database to migrate. The script will attempt to create it if it doesn't exist.
.PARAMETER User
    The username for connecting to the MySQL server.
.PARAMETER Password
    The password for the specified user.
.EXAMPLE
    .\Run-Migration.ps1 -Server "localhost" -Database "warrantybee" -User "root" -Password "your_password"
#>
param(
    [string]$Server = "localhost",
    [uint32]$Port = 3306,
    [string]$Database = "warrantybee_dev",
    [string]$User = "root",
    [string]$Password = "StrongP@ssw0rd!"
)

$PSScriptRoot = $PSScriptRoot | Split-Path
$SourceFolder =  Join-Path $PSScriptRoot

function Test-MySqlConnector {
    try {
        # Load the MySQL connector DLL directly from the local 'lib' folder.
        # This bypasses the need for Install-Package.
        $assemblyPath = Join-Path $PSScriptRoot "lib\MySqlConnector.dll"
        
        if (-not (Test-Path $assemblyPath)) {
            throw "MySql.Data.dll not found at '$assemblyPath'. Please follow the manual download instructions."
        }

        Add-Type -Path $assemblyPath
        Write-Host "MySQL Connector/NET loaded successfully." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to load MySQL Connector/NET from '$assemblyPath'. Error: $($_.Exception.Message)"
        return $false
    }
}

function Invoke-MySqlQuery {
    param(
        [Parameter(Mandatory)]
        [string]$ConnectionString,
        [string]$Sql,
        [string]$File
    )

    $connection = New-Object MySqlConnector.MySqlConnection
    $connection.ConnectionString = $ConnectionString

    try {
        $connection.Open()
        $command = $connection.CreateCommand()
        $scriptContent = ""
        if ($File) {
            Write-Verbose "Executing file: $File"
            $scriptContent = Get-Content $File -Raw
        }
        else {
            Write-Verbose "Executing SQL: $($Sql.Substring(0, [System.Math]::Min($Sql.Length, 80)))..."
            $scriptContent = $Sql
        }

        $scriptLines = $scriptContent -split '\r?\n'
        $currentDelimiter = ';'
        $commandBuilder = [System.Text.StringBuilder]::new()

        foreach ($line in $scriptLines) {
            if ($line.Trim() -match '^DELIMITER\s+(.+)$') {
                if ($commandBuilder.Length -gt 0) {
                    $command.CommandText = $commandBuilder.ToString()
                    $null = $command.ExecuteNonQuery()
                    $null = $commandBuilder.Clear()
                }
                $currentDelimiter = $matches[1].Trim()
            }
            elseif ($line.Trim() -eq $currentDelimiter) {
                if ($commandBuilder.Length -gt 0) {
                    $command.CommandText = $commandBuilder.ToString()
                    $null = $command.ExecuteNonQuery()
                    $null = $commandBuilder.Clear()
                }
            }
            else {
                $null = $commandBuilder.AppendLine($line)
            }
        }

        if ($commandBuilder.Length -gt 0) {
            $command.CommandText = $commandBuilder.ToString()
            $null = $command.ExecuteNonQuery()
        }
    }
    finally {
        if ($connection.State -eq 'Open') {
            $connection.Close()
        }
    }
}

if (-not (Test-MySqlConnector)) {
    exit 1
}

# --- Main Migration Logic ---

Write-Host "Starting database migration for '$Database' on '$Server'."

$baseConnString = "Server=$Server;Port=$Port;User=$User;Password=$Password;"
$dbConnString = $baseConnString + "Database=$Database;"

# 1. Create Database if it doesn't exist
Write-Host "Ensuring database '$Database' exists..."
Invoke-MySqlQuery -ConnectionString $baseConnString -Sql "CREATE DATABASE IF NOT EXISTS `$Database`;"

# 2. Functions
Write-Host "Applying functions..."
$funcDir = Join-Path $SourceFolder "functions"
$funcFiles = Get-ChildItem -Path $funcDir -Filter "*.sql" -Recurse
foreach ($file in $funcFiles) {
    Write-Host "  - $($file.Name)"
    Invoke-MySqlQuery -ConnectionString $dbConnString -File $file.FullName
}

# 3. Master Stored Procedures (Topologically Sorted)
Write-Host "Applying master stored procedures..."
$dependencies = Get-Content (Join-Path $SourceFolder "dependencies.json") | ConvertFrom-Json
$procDeps = $dependencies.procedures.master.PSObject.Properties | ForEach-Object { @{ Name = $_.Name; DependsOn = $_.Value.dependencies.procs } }
$resolved = @()
$unresolved = [System.Collections.Generic.List[object]]::new($procDeps)

$iterationCount = 0
while ($unresolved.Count -gt 0) {
    $resolvedThisPass = @()
    foreach ($proc in $unresolved) {
        $depsMet = $true
        foreach ($dep in $proc.DependsOn) {
            if ($dep -notin $resolved) {
                $depsMet = $false
                break
            }
        }

        if ($depsMet) {
            $resolvedThisPass += $proc
        }
    }

    if ($resolvedThisPass.Count -eq 0) {
        Write-Error "Circular dependency detected in master procedures. Halting."
        exit 1
    }

    foreach ($procToResolve in $resolvedThisPass) {
        $filePath = Join-Path $SourceFolder "procs\master\$($procToResolve.Name).sql"
        Write-Host "  - $($procToResolve.Name)"
        Invoke-MySqlQuery -ConnectionString $dbConnString -File $filePath
        $resolved += $procToResolve.Name
        $unresolved.Remove($procToResolve)
    }
    $iterationCount++
    if ($iterationCount -gt $procDeps.Count) { # Safety break
        Write-Error "Could not resolve all master procedure dependencies. Halting."
        exit 1
    }
}

# 4. Business Logic Stored Procedures
Write-Host "Applying business logic stored procedures..."
$procFiles = Get-ChildItem (Join-Path $SourceFolder "procs") -Filter "*.sql" -Recurse | Where-Object {
    $_.Directory.Name -ne 'master'
}
foreach ($file in $procFiles) {
    Write-Host "  - $($file.Name)"
    Invoke-MySqlQuery -ConnectionString $dbConnString -File $file.FullName
}

# 5. Tables (Structure and Data)
Write-Host "Applying table structures and data..."
$tableOrder = @(
    "tblCurrencies",
    "tblTimeZones",
    "tblUsers",
    "tblCountries",
    "tblStates",
    "tblUserProfiles"
)
$scriptOrder = @(
    "columns.sql",
    "constraints.sql",
    "indexes.sql",
    "foreignkeys.sql",
    "data.sql"
)

foreach ($tableName in $tableOrder) {
    Write-Host "  Processing table: $tableName"
    
    # Create the table using the master procedure
    Write-Host "    - Creating table shell..."
    Invoke-MySqlQuery -ConnectionString $dbConnString -Sql "CALL usp_CreateTable('$tableName');"

    $tablePath = Join-Path $SourceFolder "tables\$tableName"
    foreach ($scriptName in $scriptOrder) {
        $scriptFile = Join-Path $tablePath $scriptName
        if (Test-Path $scriptFile) {
            Write-Host "    - Applying $($scriptName)..."
            Invoke-MySqlQuery -ConnectionString $dbConnString -File $scriptFile
        }
    }
}

Write-Host -ForegroundColor Green "Migration completed successfully."