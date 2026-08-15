param(
    [string]$TargetRepository = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetDir = (Resolve-Path -LiteralPath $TargetRepository).Path

if ($sourceDir -eq $targetDir) {
    Write-Error "source and target are the same directory. Clone this bootstrap repository elsewhere, then run install.ps1 with your project path."
}

if (-not (Test-Path -LiteralPath (Join-Path $targetDir ".git") -PathType Container)) {
    Write-Error "target is not a Git repository: $targetDir. Initialize Git first with: git init"
}

foreach ($path in @("AGENTS.md", "CLAUDE.md", ".agents")) {
    if (Test-Path -LiteralPath (Join-Path $targetDir $path)) {
        Write-Error "refusing to overwrite existing $path in target repository"
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $sourceDir "AGENTS.md") -PathType Leaf) -or
    -not (Test-Path -LiteralPath (Join-Path $sourceDir ".agents") -PathType Container)) {
    Write-Error "bootstrap source is incomplete"
}

New-Item -ItemType Directory -Path (Join-Path $targetDir ".agents") | Out-Null
Copy-Item -LiteralPath (Join-Path $sourceDir "AGENTS.md") -Destination (Join-Path $targetDir "AGENTS.md")
Copy-Item -LiteralPath (Join-Path $sourceDir "CLAUDE.md") -Destination (Join-Path $targetDir "CLAUDE.md")
$sourceAgents = Join-Path $sourceDir ".agents"
$targetAgents = Join-Path $targetDir ".agents"
Get-ChildItem -LiteralPath $sourceAgents -Force | Copy-Item -Destination $targetAgents -Recurse

Write-Host "Installed coding-agent-bootstrap into:"
Write-Host "  $targetDir"
Write-Host ""
Write-Host "Next: start a coding-agent session in the target repository."
Write-Host "The agent should read AGENTS.md, complete .agents/BOOTSTRAP.md, keep only project-relevant context, and remove .agents/BOOTSTRAP.md after setup."
