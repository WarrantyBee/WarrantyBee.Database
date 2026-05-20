param(
    [string]$db,
    [switch]$skipdata
)

$scriptPath = $PSScriptRoot
$srcPath = Join-Path -Path $scriptPath -ChildPath "src"
$outputFile = Join-Path -Path $scriptPath -ChildPath "output.sql"

if (Test-Path $outputFile) {
    Clear-Content $outputFile
}

if (-not [string]::IsNullOrEmpty($db)) {
    $useDbStatement = "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$db')`nBEGIN`n    CREATE DATABASE [$db];`nEND`nGO`nUSE [$db];`nGO`n"
    Add-Content -Path $outputFile -Value $useDbStatement
}

Add-Content -Path $outputFile -Value "SET NOCOUNT ON;`nSET QUOTED_IDENTIFIER ON;`nGO`n`n"

function Add-ScriptContent {
    param (
        [string]$filePath
    )
    Write-Host "Merging: $filePath"
    $fileName = Split-Path -Path $filePath -Leaf
    $header = "-- Script: $fileName"
    Add-Content -Path $outputFile -Value "$header`r`n"
    $content = Get-Content -Path $filePath -Raw
    
    # Standardize line endings
    $content = $content -replace "\r?\n", "`r`n"
    
    # Remove MySQL DELIMITER
    $content = $content -replace "(?i)DELIMITER\s+[\S]+", ""
    
    # Ensure GO is on its own line
    $content = $content -replace "\$\$", "`r`nGO`r`n"
    $content = $content -replace ";\s*GO", ";`r`nGO"
    
    Add-Content -Path $outputFile -Value $content
    
    # Always append a newline and GO at the end of every merged file to ensure batch separation
    Add-Content -Path $outputFile -Value "`r`nGO`r`n`n"
}

$dependenciesPath = Join-Path -Path $srcPath -ChildPath "dependencies.json"
$dependencies = Get-Content -Path $dependenciesPath | ConvertFrom-Json

function Get-TopologicalSort {
    param (
        [System.Collections.IDictionary]$itemsWithDependencies
    )

    $sorted = [System.Collections.Generic.List[string]]::new()
    $inDegree = @{}
    $graph = @{}

    $itemNames = $itemsWithDependencies.Keys
    foreach ($item in $itemNames) {
        $inDegree[$item] = 0
        $graph[$item] = [System.Collections.Generic.List[string]]::new()
    }

    foreach ($item in $itemNames) {
        $itemDependencies = $itemsWithDependencies[$item]
        if ($itemDependencies -is [array]) {
            foreach ($dependency in $itemDependencies) {
                if ($itemNames -contains $dependency) {
                    $graph[$dependency].Add($item)
                    if ($inDegree.ContainsKey($item)) {
                        $inDegree[$item]++
                    }
                }
            }
        }
    }

    $queue = [System.Collections.Generic.Queue[string]]::new()
    foreach ($item in $inDegree.Keys) {
        if ($inDegree[$item] -eq 0) {
            $queue.Enqueue($item)
        }
    }

    while ($queue.Count -gt 0) {
        $currentItem = $queue.Dequeue()
        $sorted.Add($currentItem)

        if ($graph.ContainsKey($currentItem)) {
            foreach ($neighbor in $graph[$currentItem]) {
                $inDegree[$neighbor]--
                if ($inDegree[$neighbor] -eq 0) {
                    $queue.Enqueue($neighbor)
                }
            }
        }
    }

    if ($sorted.Count -ne $itemsWithDependencies.Count) {
        throw "Cyclic dependency detected"
    }

    return $sorted
}

# 1. Master Functions
Write-Host "Processing master functions..."
$masterFunctions = @{}
if ($dependencies.functions.master) {
    $dependencies.functions.master.PSObject.Properties | ForEach-Object {
        $masterFunctions[$_.Name] = $_.Value.dependencies.functions
    }
    $sortedMasterFunctions = Get-TopologicalSort -itemsWithDependencies $masterFunctions
    foreach ($name in $sortedMasterFunctions) {
        Add-ScriptContent -filePath (Join-Path -Path $srcPath -ChildPath "functions\master\$name.sql")
    }
}

# 2. Master Procedures
Write-Host "Processing master procedures..."
$masterProcedures = @{}
if ($dependencies.procedures.master) {
    $dependencies.procedures.master.PSObject.Properties | ForEach-Object {
        $masterProcedures[$_.Name] = $_.Value.dependencies.procs
    }
    $sortedMasterProcedures = Get-TopologicalSort -itemsWithDependencies $masterProcedures
    foreach ($name in $sortedMasterProcedures) {
        Add-ScriptContent -filePath (Join-Path -Path $srcPath -ChildPath "procs\master\$name.sql")
    }
}

# 3. Table Structure (Objects creation first)
Write-Host "Processing tables..."
$objectsFile = Join-Path -Path $srcPath -ChildPath "tables\objects.sql"
if (Test-Path $objectsFile) {
    Add-ScriptContent -filePath $objectsFile
}

$mergedTableDependencies = @{}
$dependencies.tables.PSObject.Properties | ForEach-Object {
    $mergedTableDependencies[$_.Name] = $_.Value
}
$sortedTables = Get-TopologicalSort -itemsWithDependencies $mergedTableDependencies

$tableFileOrder = @("columns.sql", "constraints.sql", "indexes.sql", "foreignkeys.sql")

foreach ($tableName in $sortedTables) {
    $tablePath = Join-Path -Path $srcPath -ChildPath "tables\$tableName"
    foreach ($fileName in $tableFileOrder) {
        $filePath = Join-Path -Path $tablePath -ChildPath $fileName
        if (Test-Path $filePath) {
            Add-ScriptContent -filePath $filePath
        }
    }
    if (-not $skipdata) {
        $dataFilePath = Join-Path -Path $tablePath -ChildPath "data.sql"
        if (Test-Path $dataFilePath) {
            Add-ScriptContent -filePath $dataFilePath
        }
    }
}

# 4. Business logic
Write-Host "Processing business logic..."
# Business Functions
if ($dependencies.functions. business) {
    $dependencies.functions.business.PSObject.Properties | ForEach-Object {
        $filePath = Join-Path -Path $srcPath -ChildPath "functions\$($_.Name).sql"
        if (-not (Test-Path $filePath)) { $filePath = Join-Path -Path $srcPath -ChildPath "functions\business\$($_.Name).sql" }
        if (Test-Path $filePath) { Add-ScriptContent -filePath $filePath }
    }
}
# Business Procedures
if ($dependencies.procedures.business) {
    $dependencies.procedures.business.PSObject.Properties | ForEach-Object {
        $filePath = Join-Path -Path $srcPath -ChildPath "procs\$($_.Name).sql"
        if (Test-Path $filePath) { Add-ScriptContent -filePath $filePath }
    }
}

Write-Host "`nMigration script 'output.sql' generated successfully."