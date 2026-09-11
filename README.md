# coding-agent-bootstrap

A small, temporary kit that teaches coding agents how to work safely in a repository.

It discovers the project, writes durable agent context, preserves existing guidance, and removes its setup scaffolding when finished.

## Quick Start

Run from the project directory and choose an agent.

Codex on macOS or Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- codex
```

Claude Code on macOS or Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- claude
```

Codex on Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.ps1))) -Agent codex
```

Claude Code on Windows PowerShell:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.ps1))) -Agent claude
```

The installer starts the selected agent in the repository with the bootstrap instructions as its initial prompt.

## What It Does

```text
install → preserve → discover → reconcile → validate → clean up
```

The installer:

- initializes Git when needed;
- creates `chore/coding-agent-bootstrap` when run from a committed default branch;
- preserves existing `AGENTS.md`, `CLAUDE.md`, and `.agents/` under `.coding-agent-bootstrap/existing/`;
- installs a temporary discovery scaffold; and
- leaves semantic project discovery and reconciliation to the coding agent.

After bootstrap, the temporary route and migration state are removed. The repository keeps only concise, project-specific agent context.

## Philosophy

Bootstrap once. Learn the repository. Preserve useful intent. Stay out of the way.

- Understand the existing project before changing it.
- Prefer project conventions over generic defaults.
- Keep instructions short, specific, and verifiable.
- Give each fact one canonical home.
- Add no runtime, daemon, or hidden persistent state.
- Keep canonical guidance vendor-neutral.

Every installed `AGENTS.md` begins with four rules: think before coding, keep it simple, make surgical changes, and work toward verifiable outcomes.

## Installed Context

```text
AGENTS.md                 short rules and routing
CLAUDE.md                 compatibility pointer
.agents/
├── WORKFLOW.md           development process
├── COMMANDS.md           exact verified commands
├── ARCHITECTURE.md       system boundaries and invariants
├── DOCTOR.md             context audit procedure
├── todos/                active and completed follow-up work
├── presets/              candidate engineering conventions
└── mcp/                  candidate external capabilities
```

The first agent replaces generic scaffolds with facts discovered from the target repository and removes irrelevant presets and capabilities.

## Defaults and Overrides

Git is the only shared installer dependency. Use a POSIX shell on macOS/Linux or PowerShell on Windows.

Existing agent configuration is preserved automatically; `--merge` and `-Merge` remain accepted for compatibility.

Omit the agent name or `-Agent` option to install without starting a session.

To intentionally install without leaving the current default branch:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- --allow-current-branch
```

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.ps1))) -AllowCurrentBranch
```

If `chore/coding-agent-bootstrap` already exists, the installer stops rather than guessing whether it is safe to reuse.

## Scope

This project configures repository context for coding agents. It is not an agent orchestrator, application generator, task scheduler, or prompt library.
