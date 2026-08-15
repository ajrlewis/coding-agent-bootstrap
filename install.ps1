param(
    [switch]$Merge,
    [Parameter(Position = 0)]
    [string]$TargetRepository = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$repositoryUrl = if ($env:CAB_INSTALL_REPOSITORY) { $env:CAB_INSTALL_REPOSITORY } else { "https://github.com/ajrlewis/coding-agent-bootstrap.git" }
$repositoryRef = if ($env:CAB_INSTALL_REF) { $env:CAB_INSTALL_REF } else { "main" }
$downloadDir = $null
$stageDir = $null
$targetDir = $null
$migrationDir = $null
$migrationInstalled = $false
$installedAgentsMd = $false
$installedClaudeMd = $false
$installedAgentsDir = $false
$existingAgentsMd = $false
$existingClaudeMd = $false
$existingAgentsDir = $false

function Copy-PreservedPath {
    param(
        [string]$Source,
        [string]$Destination
    )

    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
}

function Restore-ExistingConfiguration {
    $restoreFailed = $false
    $existingRoot = Join-Path $migrationDir "existing"

    foreach ($item in @(
        @{ Exists = $existingAgentsMd; Name = "AGENTS.md" },
        @{ Exists = $existingClaudeMd; Name = "CLAUDE.md" },
        @{ Exists = $existingAgentsDir; Name = ".agents" }
    )) {
        if (-not $item.Exists) {
            continue
        }

        $destination = Join-Path $targetDir $item.Name
        try {
            if (Test-Path -LiteralPath $destination) {
                throw "rollback destination already exists: $destination"
            }
            Copy-PreservedPath -Source (Join-Path $existingRoot $item.Name) -Destination $destination
        }
        catch {
            $restoreFailed = $true
        }
    }

    if (-not $restoreFailed) {
        Remove-Item -LiteralPath $migrationDir -Recurse -Force
    }
    else {
        Write-Warning "Automatic rollback was incomplete. Preserved configuration remains at: $existingRoot"
    }
}

try {
    if (-not (Test-Path -LiteralPath $TargetRepository -PathType Container)) {
        throw "target directory does not exist: $TargetRepository"
    }

    $targetDir = (Resolve-Path -LiteralPath $TargetRepository).Path
    $migrationDir = Join-Path $targetDir ".coding-agent-bootstrap"

    if (-not (Test-Path -LiteralPath (Join-Path $targetDir ".git") -PathType Container)) {
        throw "target is not a Git repository: $targetDir. Initialize Git first with: git init"
    }

    $sourceDir = $null
    if ($PSScriptRoot -and
        (Test-Path -LiteralPath (Join-Path $PSScriptRoot "bootstrap\AGENTS.md") -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $PSScriptRoot "bootstrap\.agents") -PathType Container)) {
        $sourceDir = $PSScriptRoot
    }

    if ($sourceDir -and $sourceDir -eq $targetDir) {
        throw "source and target are the same directory. Run the remote installer from the target, or pass a different target path."
    }

    $existingAgentsMd = Test-Path -LiteralPath (Join-Path $targetDir "AGENTS.md")
    $existingClaudeMd = Test-Path -LiteralPath (Join-Path $targetDir "CLAUDE.md")
    $existingAgentsDir = Test-Path -LiteralPath (Join-Path $targetDir ".agents")
    $hasExisting = $existingAgentsMd -or $existingClaudeMd -or $existingAgentsDir

    if ($hasExisting -and -not $Merge) {
        Write-Host "Existing coding-agent configuration detected:" -ForegroundColor Yellow
        if ($existingAgentsMd) { Write-Host "  AGENTS.md" }
        if ($existingClaudeMd) { Write-Host "  CLAUDE.md" }
        if ($existingAgentsDir) { Write-Host "  .agents/" }
        Write-Host ""
        throw "Refusing to overwrite existing configuration. Re-run with -Merge to preserve and migrate it."
    }

    if (Test-Path -LiteralPath $migrationDir) {
        throw "temporary migration state already exists: $migrationDir. Complete or remove it before running the installer again."
    }

    if ($sourceDir) {
        $payloadDir = Join-Path $sourceDir "bootstrap"
    }
    else {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            throw "Git is required to fetch the bootstrap payload"
        }

        $downloadDir = Join-Path ([System.IO.Path]::GetTempPath()) ("coding-agent-bootstrap-" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $downloadDir | Out-Null
        $checkoutDir = Join-Path $downloadDir "repository"
        Write-Host "Fetching coding-agent-bootstrap..."
        & git clone --quiet --depth 1 --branch $repositoryRef $repositoryUrl $checkoutDir
        if ($LASTEXITCODE -ne 0) {
            throw "unable to fetch coding-agent-bootstrap from $repositoryUrl"
        }
        $payloadDir = Join-Path $checkoutDir "bootstrap"
    }

    foreach ($path in @("AGENTS.md", "CLAUDE.md", ".agents", ".agents\BOOTSTRAP.md")) {
        if (-not (Test-Path -LiteralPath (Join-Path $payloadDir $path))) {
            throw "bootstrap payload is incomplete: missing $path"
        }
    }

    $stageDir = Join-Path $targetDir (".coding-agent-bootstrap-stage-" + [guid]::NewGuid().ToString("N"))
    $payloadStage = Join-Path $stageDir "payload"
    $payloadAgents = Join-Path $payloadStage ".agents"
    New-Item -ItemType Directory -Path $payloadAgents | Out-Null
    Copy-Item -LiteralPath (Join-Path $payloadDir "AGENTS.md") -Destination (Join-Path $payloadStage "AGENTS.md")
    Copy-Item -LiteralPath (Join-Path $payloadDir "CLAUDE.md") -Destination (Join-Path $payloadStage "CLAUDE.md")
    Get-ChildItem -LiteralPath (Join-Path $payloadDir ".agents") -Force | Copy-Item -Destination $payloadAgents -Recurse -Force

    if ($hasExisting) {
        $existingStage = Join-Path $stageDir "migration\existing"
        New-Item -ItemType Directory -Path $existingStage | Out-Null
        if ($existingAgentsMd) { Copy-PreservedPath -Source (Join-Path $targetDir "AGENTS.md") -Destination (Join-Path $existingStage "AGENTS.md") }
        if ($existingClaudeMd) { Copy-PreservedPath -Source (Join-Path $targetDir "CLAUDE.md") -Destination (Join-Path $existingStage "CLAUDE.md") }
        if ($existingAgentsDir) { Copy-PreservedPath -Source (Join-Path $targetDir ".agents") -Destination (Join-Path $existingStage ".agents") }

        Move-Item -LiteralPath (Join-Path $stageDir "migration") -Destination $migrationDir
        $migrationInstalled = $true

        if ($existingAgentsMd) { Remove-Item -LiteralPath (Join-Path $targetDir "AGENTS.md") -Force }
        if ($existingClaudeMd) { Remove-Item -LiteralPath (Join-Path $targetDir "CLAUDE.md") -Force }
        if ($existingAgentsDir) { Remove-Item -LiteralPath (Join-Path $targetDir ".agents") -Recurse -Force }
    }

    Move-Item -LiteralPath (Join-Path $payloadStage "AGENTS.md") -Destination (Join-Path $targetDir "AGENTS.md")
    $installedAgentsMd = $true
    Move-Item -LiteralPath (Join-Path $payloadStage "CLAUDE.md") -Destination (Join-Path $targetDir "CLAUDE.md")
    $installedClaudeMd = $true
    Move-Item -LiteralPath $payloadAgents -Destination (Join-Path $targetDir ".agents")
    $installedAgentsDir = $true

    Write-Host "Installed coding-agent-bootstrap into:"
    Write-Host "  $targetDir"
    if ($hasExisting) {
        Write-Host ""
        Write-Host "Existing coding-agent configuration was preserved at:"
        Write-Host "  .coding-agent-bootstrap/existing/"
    }
    Write-Host ""
    Write-Host "Next: start a coding-agent session in the target repository."
    Write-Host "The agent should read AGENTS.md and complete .agents/BOOTSTRAP.md before normal project work."
}
catch {
    $installError = $_
    if ($installedAgentsMd) { Remove-Item -LiteralPath (Join-Path $targetDir "AGENTS.md") -Force -ErrorAction SilentlyContinue }
    if ($installedClaudeMd) { Remove-Item -LiteralPath (Join-Path $targetDir "CLAUDE.md") -Force -ErrorAction SilentlyContinue }
    if ($installedAgentsDir) { Remove-Item -LiteralPath (Join-Path $targetDir ".agents") -Recurse -Force -ErrorAction SilentlyContinue }
    if ($migrationInstalled) { Restore-ExistingConfiguration }
    Write-Error $installError
}
finally {
    if ($stageDir -and (Test-Path -LiteralPath $stageDir)) {
        Remove-Item -LiteralPath $stageDir -Recurse -Force
    }
    if ($downloadDir -and (Test-Path -LiteralPath $downloadDir)) {
        Remove-Item -LiteralPath $downloadDir -Recurse -Force
    }
}
