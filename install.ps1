param(
    [string]$TargetRepository = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$repositoryUrl = if ($env:CAB_INSTALL_REPOSITORY) { $env:CAB_INSTALL_REPOSITORY } else { "https://github.com/ajrlewis/coding-agent-bootstrap.git" }
$repositoryRef = if ($env:CAB_INSTALL_REF) { $env:CAB_INSTALL_REF } else { "main" }
$downloadDir = $null
$stageDir = $null
$installedAgentsMd = $false
$installedClaudeMd = $false
$installedAgentsDir = $false

try {
    if (-not (Test-Path -LiteralPath $TargetRepository -PathType Container)) {
        throw "target directory does not exist: $TargetRepository"
    }

    $targetDir = (Resolve-Path -LiteralPath $TargetRepository).Path

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

    foreach ($path in @("AGENTS.md", "CLAUDE.md", ".agents")) {
        if (Test-Path -LiteralPath (Join-Path $targetDir $path)) {
            throw "refusing to overwrite existing $path in target repository"
        }
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

    $stageDir = Join-Path $targetDir (".coding-agent-bootstrap-" + [guid]::NewGuid().ToString("N"))
    $stageAgents = Join-Path $stageDir ".agents"
    New-Item -ItemType Directory -Path $stageAgents | Out-Null
    Copy-Item -LiteralPath (Join-Path $payloadDir "AGENTS.md") -Destination (Join-Path $stageDir "AGENTS.md")
    Copy-Item -LiteralPath (Join-Path $payloadDir "CLAUDE.md") -Destination (Join-Path $stageDir "CLAUDE.md")
    Get-ChildItem -LiteralPath (Join-Path $payloadDir ".agents") -Force | Copy-Item -Destination $stageAgents -Recurse

    Move-Item -LiteralPath (Join-Path $stageDir "AGENTS.md") -Destination (Join-Path $targetDir "AGENTS.md")
    $installedAgentsMd = $true
    Move-Item -LiteralPath (Join-Path $stageDir "CLAUDE.md") -Destination (Join-Path $targetDir "CLAUDE.md")
    $installedClaudeMd = $true
    Move-Item -LiteralPath $stageAgents -Destination (Join-Path $targetDir ".agents")
    $installedAgentsDir = $true

    Write-Host "Installed coding-agent-bootstrap into:"
    Write-Host "  $targetDir"
    Write-Host ""
    Write-Host "Next: start a coding-agent session in the target repository."
    Write-Host "The agent should read AGENTS.md and complete .agents/BOOTSTRAP.md before normal project work."
}
catch {
    if ($installedAgentsMd) { Remove-Item -LiteralPath (Join-Path $targetDir "AGENTS.md") -Force -ErrorAction SilentlyContinue }
    if ($installedClaudeMd) { Remove-Item -LiteralPath (Join-Path $targetDir "CLAUDE.md") -Force -ErrorAction SilentlyContinue }
    if ($installedAgentsDir) { Remove-Item -LiteralPath (Join-Path $targetDir ".agents") -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Error $_
}
finally {
    if ($stageDir -and (Test-Path -LiteralPath $stageDir)) {
        Remove-Item -LiteralPath $stageDir -Recurse -Force
    }
    if ($downloadDir -and (Test-Path -LiteralPath $downloadDir)) {
        Remove-Item -LiteralPath $downloadDir -Recurse -Force
    }
}
