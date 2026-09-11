# Architecture

`coding-agent-bootstrap` is a static bootstrap kit.

## Components

- Root `AGENTS.md`, `CLAUDE.md`, and `.agents/` configure agents developing this repository.
- `bootstrap/` is the complete payload copied into target repositories. Its project-context files are temporary writing scaffolds; its doctor procedure, preset library, and MCP library are reusable discovery material.
- `install.sh` selects the local payload when run from a checkout or fetches a temporary checkout when run from standard input. It preserves direct conflicts under `.coding-agent-bootstrap/existing/` by default; `--merge` remains a compatibility option. The optional `codex` or `claude` action starts that CLI with the bootstrap prompt after a successful install.
- `install.ps1` provides equivalent local and remote Windows behavior, including optional `-Agent codex` or `-Agent claude` startup, with `-Merge` retained for compatibility; `install.bat` is its local compatibility entrypoint.
- `tests/install.sh` and `tests/install.ps1` exercise platform-specific installation, Git initialization, branch creation, default merge-preservation, refusal, and rollback behavior.
- `tests/context.sh` checks deterministic agent-context invariants that do not require semantic repository judgment.
- `.github/workflows/ci.yml` runs POSIX/context verification on Linux and native PowerShell verification on Windows for pull requests targeting `main`.

## Boundaries

- Root agent context must never be installed into target repositories.
- Installers copy only `bootstrap/AGENTS.md`, `bootstrap/CLAUDE.md`, and `bootstrap/.agents/`.
- Installers validate and transfer files. They preserve conflicting configuration bytes but do not interpret content; semantic reconciliation belongs to the coding agent.
- No runtime service, daemon, orchestration layer, or application generator belongs here.
- Host-specific files must be thin adapters that point back to canonical context.
- Installers copy repository context only. They must not install global tools, package managers, provider CLIs, credentials, or user-level agent configuration.
- Shell and PowerShell implementations should preserve equivalent conflict-preservation and Git setup behavior.
- CI checks host-native behavior directly; containers are optional portability coverage, not a substitute for Windows verification.
- Only direct overwrite conflicts (`AGENTS.md`, `CLAUDE.md`, and `.agents/`) are preserved by installers. Other agent guidance is discovered during bootstrap.

## Invariants

- Root and payload `AGENTS.md` files stay short and route to their respective canonical context.
- Exact project commands live in the relevant `.agents/COMMANDS.md`, not presets or skills.
- Only the payload contains `.agents/BOOTSTRAP.md`; installed repositories remove it and its `AGENTS.md` routing paragraph after first-run configuration.
- Active and completed agent-managed follow-up work stay separate under `.agents/todos/`.
- Installed target repositories should keep only adopted presets, project-specific skills, and desired MCP capabilities.
- Default installation must preserve existing `AGENTS.md`, `CLAUDE.md`, or `.agents/` before replacement and retain recoverable state on failure.
- Installers initialize Git when needed. From a committed default branch they create and switch to `chore/coding-agent-bootstrap` unless the user supplies the explicit current-branch override; unborn repositories and existing feature branches remain on their current branch.
- Installer runtime requirements stay limited to Git and the host script environment; tools needed only by an adopted target-project workflow are discovered after installation.
- `.coding-agent-bootstrap/` is temporary merge state and must remain until semantic migration is validated.
