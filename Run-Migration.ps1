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
    $useDbStatement = "USE $db;`n"
    Add-Content -Path $outputFile -Value $useDbStatement
}

$setUTCTimezone = "SET time_zone = '+00:00';`nSET sql_require_primary_key = OFF;`n`n"
Add-Content -Path $outputFile -Value $setUTCTimezone

function Add-ScriptContent {
    param (
        [string]$filePath
    )
    Write-Host "Merging: $filePath"
    $fileName = Split-Path -Path $filePath -Leaf
    $header = "-- Script: $fileName"
    Add-Content -Path $outputFile -Value "$header`r`n"
    $content = Get-Content -Path $filePath -Raw
    Add-Content -Path $outputFile -Value "$content`r`n`r`n"
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

    # Initialize graph and in-degree
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
        $unsortedItems = $itemsWithDependencies.Keys | Where-Object { -not ($sorted -contains $_) }
        throw "Cyclic dependency detected or missing dependency. Unsorted items: $($unsortedItems -join ', ')"
    }

    return $sorted
}


Write-Host "Processing functions..."
$allFunctions = @{}
$dependencies.functions.PSObject.Properties | ForEach-Object {
    $folder = $_.Name
    $_.Value.PSObject.Properties | ForEach-Object {
        $functionName = $_.Name
        $deps = $_.Value.dependencies.functions
        $allFunctions[$functionName] = $deps
    }
}
$sortedFunctions = Get-TopologicalSort -itemsWithDependencies $allFunctions
foreach ($functionName in $sortedFunctions) {
    $filePath = Join-Path -Path $srcPath -ChildPath "functions\master\$functionName.sql"
    if (Test-Path $filePath) {
        Add-ScriptContent -filePath $filePath
    }
}

Write-Host "`nProcessing master procedures..."
$masterProcedures = @{}
if ($dependencies.procedures.master) {
    $dependencies.procedures.master.PSObject.Properties | ForEach-Object {
        $procName = $_.Name
        $deps = $_.Value.dependencies.procs
        $masterProcedures[$procName] = $deps
    }
    $sortedMasterProcedures = Get-TopologicalSort -itemsWithDependencies $masterProcedures
    foreach ($procName in $sortedMasterProcedures) {
        $filePath = Join-Path -Path $srcPath -ChildPath "procs\master\$procName.sql"
        if (Test-Path $filePath) {
            Add-ScriptContent -filePath $filePath
        }
    }
}

Write-Host "`nProcessing tables..."
$mergedTableDependencies = @{}
$dependencies.tables.PSObject.Properties | ForEach-Object {
    $mergedTableDependencies[$_.Name] = $_.Value
}
$sortedTables = Get-TopologicalSort -itemsWithDependencies $mergedTableDependencies

$tableFileOrder = @("columns.sql", "constraints.sql", "indexes.sql", "foreignkeys.sql")

$objectsFile = Join-Path -Path $srcPath -ChildPath "tables\objects.sql"
if (Test-Path $objectsFile) {
    Add-ScriptContent -filePath $objectsFile
}

foreach ($tableName in $sortedTables) {
    $tablePath = Join-Path -Path $srcPath -ChildPath "tables\$tableName"
    if (Test-Path $tablePath) {
        foreach ($fileName in $tableFileOrder) {
            $filePath = Join-Path -Path $tablePath -ChildPath $fileName
            if (Test-Path $filePath) {
                Add-ScriptContent -filePath $filePath
            }
        }

        $triggersPath = Join-Path -Path $tablePath -ChildPath "triggers"
        if (Test-Path $triggersPath) {
            $triggerFiles = @("before_insert.sql", "before_update.sql")
            foreach ($triggerFile in $triggerFiles) {
                $triggerPath = Join-Path -Path $triggersPath -ChildPath $triggerFile
                if (Test-Path $triggerPath) {
                    Add-ScriptContent -filePath $triggerPath
                }
            }
        }

        if (-not $skipdata) {
            $dataFilePath = Join-Path -Path $tablePath -ChildPath "data.sql"
            if (Test-Path $dataFilePath) {
                Add-ScriptContent -filePath $dataFilePath
            }
        }
    }
}

Write-Host "`nProcessing business procedures..."
$businessProcedures = @{}
if ($dependencies.procedures.business) {
    $dependencies.procedures.business.PSObject.Properties | ForEach-Object {
        $procName = $_.Name
        $deps = $_.Value.dependencies.procs
        $businessProcedures[$procName] = $deps
    }
    $sortedBusinessProcedures = Get-TopologicalSort -itemsWithDependencies $businessProcedures
    foreach ($procName in $sortedBusinessProcedures) {
        $filePath = Join-Path -Path $srcPath -ChildPath "procs\$procName.sql"
        if (Test-Path $filePath) {
            Add-ScriptContent -filePath $filePath
        }
    }
}

Write-Host "`nMigration script 'output.sql' generated successfully."