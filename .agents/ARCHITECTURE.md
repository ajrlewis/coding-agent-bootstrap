# Architecture

`coding-agent-bootstrap` is a static bootstrap kit.

## Components

- Root `AGENTS.md`, `CLAUDE.md`, and `.agents/` configure agents developing this repository.
- `bootstrap/` is the complete payload copied into target repositories. Its canonical files are temporary writing scaffolds; its preset, skill, and MCP directories are the reusable discovery library.
- `install.sh` selects the local payload when run from a checkout or fetches a temporary checkout when run from standard input. Its explicit `--merge` mode preserves direct conflicts under `.coding-agent-bootstrap/existing/`.
- `install.ps1` provides equivalent local, remote, and `-Merge` Windows behavior; `install.bat` is its local compatibility entrypoint.
- `tests/install.sh` exercises shell installation and safety behavior without adding a runtime dependency.

## Boundaries

- Root agent context must never be installed into target repositories.
- Installers copy only `bootstrap/AGENTS.md`, `bootstrap/CLAUDE.md`, and `bootstrap/.agents/`.
- Installers validate and transfer files. In merge mode they preserve bytes but do not interpret content; semantic reconciliation belongs to the coding agent.
- No runtime service, daemon, orchestration layer, or application generator belongs here.
- Host-specific files must be thin adapters that point back to canonical context.
- Shell and PowerShell implementations should preserve equivalent overwrite refusal and Git-repository checks.
- Only direct overwrite conflicts (`AGENTS.md`, `CLAUDE.md`, and `.agents/`) are preserved by installers. Other agent guidance is discovered during bootstrap.

## Invariants

- Root and payload `AGENTS.md` files stay short and route to their respective canonical context.
- Exact project commands live in the relevant `.agents/COMMANDS.md`, not presets or skills.
- Only the payload contains `.agents/BOOTSTRAP.md`; installed repositories remove it after first-run configuration.
- Installed target repositories should keep only adopted presets, useful skills, and desired MCP capabilities.
- Default installation must refuse existing `AGENTS.md`, `CLAUDE.md`, or `.agents/`. Merge mode must preserve them before replacement and retain recoverable state on failure.
- Installers must refuse a committed default branch unless the user supplies the explicit current-branch override; unborn repositories remain installable.
- `.coding-agent-bootstrap/` is temporary merge state and must remain until semantic migration is validated.
