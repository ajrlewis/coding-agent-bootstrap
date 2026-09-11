$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$installer = Join-Path $rootDir "install.ps1"
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("coding-agent-bootstrap-tests-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $testRoot | Out-Null

function Fail-Test {
    param([string]$Message)
    throw "FAIL: $Message"
}

function New-TestRepository {
    param(
        [string]$Name,
        [switch]$Committed
    )

    $repository = Join-Path $testRoot $Name
    New-Item -ItemType Directory -Path $repository | Out-Null
    if ($Committed) {
        & git -C $repository init --quiet --initial-branch=main
        & git -C $repository config user.name "Installer Test"
        & git -C $repository config user.email "installer-test@example.invalid"
        Set-Content -LiteralPath (Join-Path $repository "tracked.txt") -Value "tracked fixture"
        & git -C $repository add tracked.txt
        & git -C $repository commit --quiet -m "Initial fixture"
    }
    else {
        & git -C $repository init --quiet
    }
    if ($LASTEXITCODE -ne 0) {
        Fail-Test "could not initialize test repository: $Name"
    }
    return $repository
}

function Invoke-InstallerProcess {
    param([string[]]$InstallerArguments)

    $output = & pwsh -NoProfile -File $installer @InstallerArguments 2>&1 | Out-String
    return @{
        ExitCode = $LASTEXITCODE
        Output = $output
    }
}

function Assert-Succeeded {
    param(
        [hashtable]$Result,
        [string]$Description
    )

    if ($Result.ExitCode -ne 0) {
        Write-Host $Result.Output
        Fail-Test "$Description failed"
    }
}

function Assert-FailedWith {
    param(
        [hashtable]$Result,
        [string]$Expected,
        [string]$Description
    )

    if ($Result.ExitCode -eq 0) {
        Fail-Test "$Description unexpectedly succeeded"
    }
    if (-not $Result.Output.Contains($Expected)) {
        Write-Host $Result.Output
        Fail-Test "$Description did not report: $Expected"
    }
}

function Assert-FileBytesEqual {
    param(
        [string]$Expected,
        [string]$Actual,
        [string]$Description
    )

    $expectedBytes = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($Expected))
    $actualBytes = [Convert]::ToBase64String([System.IO.File]::ReadAllBytes($Actual))
    if ($expectedBytes -ne $actualBytes) {
        Fail-Test "$Description differ"
    }
}

function Assert-NoStagingFiles {
    param([string]$Repository)

    $stagingFiles = Get-ChildItem -LiteralPath $Repository -Filter ".coding-agent-bootstrap-stage-*" -Force
    if ($stagingFiles) {
        Fail-Test "installer left staging files in $Repository"
    }
}

try {
    Write-Host "Testing local PowerShell installation..."
    $repository = New-TestRepository "local-target"
    $result = Invoke-InstallerProcess @($repository)
    Assert-Succeeded $result "local installation"
    foreach ($path in @(
        "AGENTS.md",
        "CLAUDE.md",
        ".agents\BOOTSTRAP.md",
        ".agents\DOCTOR.md",
        ".agents\todos\TODO.md",
        ".agents\todos\DONE.md",
        ".agents\presets\git\azure-devops.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repository $path) -PathType Leaf)) {
            Fail-Test "local installation omitted $path"
        }
    }
    Assert-FileBytesEqual (Join-Path $rootDir "bootstrap\AGENTS.md") (Join-Path $repository "AGENTS.md") "installed AGENTS.md and payload AGENTS.md"
    Assert-NoStagingFiles $repository

    Write-Host "Testing PowerShell install-branch creation..."
    $repository = New-TestRepository "default-branch" -Committed
    $result = Invoke-InstallerProcess @($repository)
    Assert-Succeeded $result "install-branch creation"
    $currentBranch = (& git -C $repository branch --show-current).Trim()
    if ($currentBranch -ne "chore/coding-agent-bootstrap") {
        Fail-Test "installer did not create the focused branch"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $repository ".agents\BOOTSTRAP.md") -PathType Leaf)) {
        Fail-Test "install-branch creation did not install payload"
    }

    Write-Host "Testing PowerShell install-branch collision..."
    $repository = New-TestRepository "existing-install-branch" -Committed
    & git -C $repository branch chore/coding-agent-bootstrap
    $result = Invoke-InstallerProcess @($repository)
    Assert-FailedWith $result "install branch already exists: chore/coding-agent-bootstrap" "install-branch collision"
    $currentBranch = (& git -C $repository branch --show-current).Trim()
    if ($currentBranch -ne "main") {
        Fail-Test "install-branch collision changed the current branch"
    }
    if (Test-Path -LiteralPath (Join-Path $repository "AGENTS.md")) {
        Fail-Test "install-branch collision installed AGENTS.md"
    }

    Write-Host "Testing PowerShell default-branch override..."
    $repository = New-TestRepository "allowed-default-branch" -Committed
    $result = Invoke-InstallerProcess @("-AllowCurrentBranch", $repository)
    Assert-Succeeded $result "default-branch override"
    $currentBranch = (& git -C $repository branch --show-current).Trim()
    if ($currentBranch -ne "main") {
        Fail-Test "default-branch override changed the current branch"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $repository ".agents\BOOTSTRAP.md") -PathType Leaf)) {
        Fail-Test "default-branch override did not install payload"
    }

    Write-Host "Testing PowerShell automatic Git initialization..."
    $repository = Join-Path $testRoot "not-git"
    New-Item -ItemType Directory -Path $repository | Out-Null
    $result = Invoke-InstallerProcess @($repository)
    Assert-Succeeded $result "automatic Git initialization"
    if (-not (Test-Path -LiteralPath (Join-Path $repository ".git") -PathType Container)) {
        Fail-Test "installer did not initialize Git"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $repository ".agents\BOOTSTRAP.md") -PathType Leaf)) {
        Fail-Test "Git initialization did not install payload"
    }

    Write-Host "Testing PowerShell default preservation..."
    $repository = New-TestRepository "default-preservation"
    Set-Content -LiteralPath (Join-Path $repository "AGENTS.md") -Value "existing"
    $result = Invoke-InstallerProcess @($repository)
    Assert-Succeeded $result "default merge installation"
    $preservedAgents = Join-Path $repository ".coding-agent-bootstrap\existing\AGENTS.md"
    if ((Get-Content -LiteralPath $preservedAgents -Raw).Trim() -ne "existing") {
        Fail-Test "default install did not preserve AGENTS.md"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $repository ".agents\BOOTSTRAP.md") -PathType Leaf)) {
        Fail-Test "default merge did not install payload"
    }

    Write-Host "Testing PowerShell merge preservation..."
    $repository = New-TestRepository "merge-preservation"
    [System.IO.File]::WriteAllText((Join-Path $repository "AGENTS.md"), "existing agents without trailing newline")
    Set-Content -LiteralPath (Join-Path $repository "CLAUDE.md") -Value "existing claude"
    New-Item -ItemType Directory -Path (Join-Path $repository ".agents\nested") | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $repository ".agents\nested\context.md"), "nested bytes")
    $expectedAgents = Join-Path $testRoot "expected-agents.md"
    $expectedClaude = Join-Path $testRoot "expected-claude.md"
    $expectedContext = Join-Path $testRoot "expected-context.md"
    Copy-Item -LiteralPath (Join-Path $repository "AGENTS.md") -Destination $expectedAgents
    Copy-Item -LiteralPath (Join-Path $repository "CLAUDE.md") -Destination $expectedClaude
    Copy-Item -LiteralPath (Join-Path $repository ".agents\nested\context.md") -Destination $expectedContext
    $result = Invoke-InstallerProcess @("-Merge", $repository)
    Assert-Succeeded $result "merge installation"
    $preservedRoot = Join-Path $repository ".coding-agent-bootstrap\existing"
    Assert-FileBytesEqual $expectedAgents (Join-Path $preservedRoot "AGENTS.md") "preserved AGENTS.md and original"
    Assert-FileBytesEqual $expectedClaude (Join-Path $preservedRoot "CLAUDE.md") "preserved CLAUDE.md and original"
    Assert-FileBytesEqual $expectedContext (Join-Path $preservedRoot ".agents\nested\context.md") "preserved nested context and original"
    Assert-NoStagingFiles $repository

    Write-Host "Testing PowerShell rollback after preservation..."
    $repository = New-TestRepository "rollback"
    [System.IO.File]::WriteAllText((Join-Path $repository "AGENTS.md"), "restore after installer failure")
    $expectedRollback = Join-Path $testRoot "expected-rollback-agents.md"
    Copy-Item -LiteralPath (Join-Path $repository "AGENTS.md") -Destination $expectedRollback
    $global:CodingAgentBootstrapInjectMoveFailure = $true
    function global:Move-Item {
        param(
            [Parameter(Mandatory = $true)][string]$LiteralPath,
            [Parameter(Mandatory = $true)][string]$Destination,
            [switch]$Force
        )

        if ($global:CodingAgentBootstrapInjectMoveFailure -and $LiteralPath -match "[\\/]payload[\\/]AGENTS\.md$") {
            $global:CodingAgentBootstrapInjectMoveFailure = $false
            throw "injected payload move failure"
        }
        Microsoft.PowerShell.Management\Move-Item @PSBoundParameters
    }
    $rollbackFailed = $false
    try {
        & $installer -Merge $repository *> $null
    }
    catch {
        $rollbackFailed = $true
    }
    finally {
        Remove-Item -LiteralPath Function:\Move-Item -Force
        Remove-Variable -Name CodingAgentBootstrapInjectMoveFailure -Scope Global -ErrorAction SilentlyContinue
    }
    if (-not $rollbackFailed) {
        Fail-Test "injected post-preservation failure unexpectedly succeeded"
    }
    Assert-FileBytesEqual $expectedRollback (Join-Path $repository "AGENTS.md") "restored AGENTS.md and original"
    if (Test-Path -LiteralPath (Join-Path $repository "CLAUDE.md")) {
        Fail-Test "rollback left payload CLAUDE.md"
    }
    if (Test-Path -LiteralPath (Join-Path $repository ".agents")) {
        Fail-Test "rollback left payload .agents"
    }
    if (Test-Path -LiteralPath (Join-Path $repository ".coding-agent-bootstrap")) {
        Fail-Test "successful rollback left migration state"
    }
    Assert-NoStagingFiles $repository

    Write-Host "All PowerShell installer tests passed."
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}
