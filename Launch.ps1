param([string]$GodotPath='', [switch]$CheckOnly, [switch]$Smoke)
$ErrorActionPreference = 'Stop'
$taskProject = $PSScriptRoot
$taskEngine = $null

if ($GodotPath) {
    $taskEngine = $GodotPath
} elseif ($env:GODOT_BIN) {
    $taskEngine = $env:GODOT_BIN
} else {
    $taskBundled = Join-Path $taskProject 'engine/Godot_v4.7.2-stable_win64_console.exe'
    if (Test-Path -LiteralPath $taskBundled -PathType Leaf) {
        $taskEngine = $taskBundled
    } else {
        foreach ($taskName in @('godot4', 'godot', 'Godot_v4.7.2-stable_win64_console')) {
            $taskCommand = Get-Command $taskName -CommandType Application -ErrorAction SilentlyContinue
            if ($taskCommand) { $taskEngine = $taskCommand.Source; break }
        }
    }
}
if (-not $taskEngine -or -not (Test-Path -LiteralPath $taskEngine -PathType Leaf)) {
    throw 'Godot not found. Install Godot 4.7.2 and pass -GodotPath or set GODOT_BIN, or download the Windows portable ZIP. See README.md.'
}
$taskLogs = Join-Path $taskProject 'launch-logs'
New-Item -ItemType Directory -Path $taskLogs -Force | Out-Null
$taskImportLog = Join-Path $taskLogs 'import.log'
& $taskEngine --headless --editor --path $taskProject --import --log-file $taskImportLog
if ($LASTEXITCODE -ne 0) { throw 'Import failed. See launch-logs/import.log.' }
if ((Get-Content -LiteralPath $taskImportLog -Raw) -match '(?m)^(SCRIPT ERROR|ERROR):') {
    throw 'Godot reported an import error. See launch-logs/import.log.'
}
if ($Smoke) {
    & $taskEngine --headless --path $taskProject --script res://tests/smoke.gd --log-file (Join-Path $taskLogs 'smoke.log')
    exit $LASTEXITCODE
}
if ($CheckOnly) { Write-Output 'Import verified. Ready to play.'; exit 0 }
& $taskEngine --path $taskProject --log-file (Join-Path $taskLogs 'play.log')
exit $LASTEXITCODE
