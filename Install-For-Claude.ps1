# Installs the standalone After Effects MCP for Claude Code, plus the motion design skills.
# Run via Install-For-Claude.cmd, or:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-For-Claude.ps1
# Options:
#   -AllowEdits            register with editing enabled (default: read-only)
#   -AfterEffectsExe PATH  AfterFX.exe if After Effects is not in the default Adobe folder
#   -SkipSkills            install the MCP only
#   -InstallRoot / -DispatcherDirectory / -ClaudeConfig / -SkillsDir   override locations
[CmdletBinding()]
param(
    [string]$InstallRoot = (Join-Path $env:LOCALAPPDATA 'AfterEffectsMCP'),
    [string]$DispatcherDirectory,
    [string]$ClaudeConfig = (Join-Path $env:USERPROFILE '.claude.json'),
    [string]$SkillsDir = (Join-Path $env:USERPROFILE '.claude\skills'),
    [string]$AfterEffectsExe,
    [switch]$AllowEdits,
    [switch]$SkipSkills
)
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$zipName = 'After-Effects-MCP-Work-Windows-x64-2026-10-14.zip'
$zip = Join-Path $here "package\$zipName"
$work = $null

function Step([string]$m) { Write-Host "`n== $m" -ForegroundColor Cyan }

try {
    if (-not [Environment]::Is64BitOperatingSystem) { throw 'This package needs 64-bit Windows.' }

    Step 'Checking the release package'
    $expected = (Get-Content -LiteralPath "$zip.sha256" -Raw).Trim().Substring(0, 64).ToLower()
    $actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLower()
    if ($expected -ne $actual) { throw "Checksum mismatch for $zipName. The file is damaged or altered; get a fresh copy." }
    Write-Host 'Checksum OK.'

    Step 'Extracting (this can take a few minutes while antivirus scans the files)'
    $work = Join-Path $env:TEMP ('aemcp-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $work | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $work
    $marker = Get-ChildItem -LiteralPath $work -Recurse -Filter 'BUNDLE-INFO.json' | Select-Object -First 1
    if (-not $marker) { throw 'Package root (BUNDLE-INFO.json) not found inside the release zip.' }
    $pkg = $marker.DirectoryName

    Step 'Verifying every file in the release'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $pkg 'Verify-Integrity.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Integrity check failed. Nothing was installed.' }

    Step "Installing the MCP to $InstallRoot"
    $installArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Join-Path $pkg 'Install.ps1'), '-InstallRoot', $InstallRoot, '-SkipRegistration')
    if ($AfterEffectsExe) { $installArgs += @('-AfterEffectsExe', $AfterEffectsExe) }
    if ($DispatcherDirectory) { $installArgs += @('-DispatcherDirectory', $DispatcherDirectory) }
    & powershell.exe @installArgs
    if ($LASTEXITCODE -ne 0) { throw 'The MCP installer failed. Read the error above.' }
    $info = Get-Content -LiteralPath (Join-Path $InstallRoot 'installation.json') -Raw | ConvertFrom-Json

    Step 'Registering with Claude Code'
    $node = Join-Path $InstallRoot 'runtime\node.exe'
    $ro = if ($AllowEdits) { '0' } else { '1' }
    & $node (Join-Path $here 'scripts\register-claude.cjs') $ClaudeConfig $InstallRoot $info.afterEffectsExe $info.dispatcher $ro
    if ($LASTEXITCODE -ne 0) { throw 'Claude registration failed. Your Claude config was not changed.' }

    if (-not $SkipSkills) {
        Step "Installing skills to $SkillsDir"
        New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
        foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $here 'skills') -Directory) {
            $dest = Join-Path $SkillsDir $skill.Name
            if (Test-Path -LiteralPath $dest) {
                Write-Host "  kept existing $($skill.Name) (not overwritten)"
            } else {
                Copy-Item -LiteralPath $skill.FullName -Destination $dest -Recurse
                Write-Host "  installed $($skill.Name)"
            }
        }
    }

    Step 'Offline self-test (does not launch After Effects)'
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $InstallRoot 'Test-Connection.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Offline self-test failed. See the report in the installed logs folder.' }

    Write-Host "`nDone." -ForegroundColor Green
    Write-Host "Mode: $(if ($AllowEdits) { 'editing enabled' } else { 'read-only (rerun with -AllowEdits to enable editing)' })"
    Write-Host 'Next:'
    Write-Host '  1. Fully quit and reopen Claude (on Windows, quit from the system tray), or start a new Claude Code session.'
    Write-Host '  2. Open After Effects with a project, and turn on Edit > Preferences > Scripting & Expressions >'
    Write-Host '     "Allow Scripts to Write Files and Access Network".'
    Write-Host '  3. Live check (read-only, changes nothing):'
    Write-Host "     powershell -NoProfile -ExecutionPolicy Bypass -File `"$InstallRoot\Test-Connection.ps1`" -Live"
    Write-Host '  4. In Claude, ask: "Call ae_version_info and ae_project_info on after-effects-local and tell me what you see."'
}
catch {
    Write-Host "`nINSTALL FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    if ($work -and (Test-Path -LiteralPath $work)) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
}
