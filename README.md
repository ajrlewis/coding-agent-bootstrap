# coding-agent-bootstrap

`coding-agent-bootstrap` is a temporary bootstrap kit for making software repositories coding-agent-ready.

It installs a small set of agent instructions into a repository, asks the coding agent to learn the project, preserves durable context, and then removes the temporary bootstrap machinery.

```text
install -> discover -> configure -> validate -> remove bootstrap
```

The generated agent context remains with the target project. The bootstrap itself should stay out of the way.

## Quick Start

Clone the bootstrap repository, then run the installer from or against the target Git repository.

Linux/macOS:

```sh
git clone git@github.com:ajrlewis/coding-agent-bootstrap.git /tmp/coding-agent-bootstrap
cd /path/to/target/repository
/tmp/coding-agent-bootstrap/install.sh .
```

Windows:

```bat
git clone git@github.com:ajrlewis/coding-agent-bootstrap.git %TEMP%\coding-agent-bootstrap
cd C:\path\to\target\repository
%TEMP%\coding-agent-bootstrap\install.bat .
```

Then start a coding-agent session in the target repository and have it follow `AGENTS.md` and `.agents/BOOTSTRAP.md`.

## Why

Coding agents often enter repositories without knowing the actual development commands, architecture boundaries, project-specific workflow, technology conventions, persistent unfinished context, or external capabilities available to them.

Without explicit project context they repeatedly rediscover the same facts, make assumptions, create unnecessary abstractions, or use incorrect commands.

This project establishes a lightweight protocol for durable coding-agent context.

## Design Philosophy

Bootstrap once. Learn the repo. Preserve only useful context. Stay out of the way.

- Bootstrap once, then remove temporary setup state.
- Inspect before asking.
- Infer before prompting.
- Preserve only useful, durable context.
- Keep `AGENTS.md` short.
- Avoid duplicated instructions.
- Use existing project conventions first.
- Make surgical changes.
- Verify outcomes.
- Leave no unnecessary runtime behind.
- Remain vendor-neutral.

This is not an agent framework. The installer is intentionally dumb; the intelligence belongs in the coding agent after installation.

## The Four Rules

The root `AGENTS.md` starts with four rules:

1. Think before coding.
2. Keep it simple.
3. Make surgical changes.
4. Work toward verifiable outcomes.

These belong in the root file because every agent should see them immediately. Detailed commands, architecture, workflow, presets, skills, and MCP capability intent live in `.agents/` so the root stays short.

## Repository Structure

Canonical durable context:

```text
AGENTS.md
.agents/
├── VERSION
├── WORKFLOW.md
├── COMMANDS.md
├── ARCHITECTURE.md
├── TODO.md
├── presets/
├── skills/
└── mcp/
```

Temporary setup state:

```text
.agents/BOOTSTRAP.md
```

`BOOTSTRAP.md` should be removed after the first coding-agent setup pass succeeds.

## Canonical Context

- `.agents/WORKFLOW.md` describes how development work normally proceeds.
- `.agents/COMMANDS.md` records canonical known-good commands.
- `.agents/ARCHITECTURE.md` captures the mental model needed to make safe changes.
- `.agents/TODO.md` stores persistent agent-relevant follow-up work.

These files are concise project-specific sources of truth. They are agent-managed, which means coding agents are expected to keep them accurate when their work changes the facts they describe. Humans may edit them too.

## Presets

Presets capture adopted engineering opinions:

- GitHub flow
- Next.js
- Bun
- Python and uv
- FastAPI
- PostgreSQL
- Supabase
- Alembic
- Prisma
- Docker
- GitHub Actions
- pre-commit

The name `presets` is intentional. A template suggests blindly copying content. A preset is a starting opinion that should be reconciled with the actual repository.

Existing project conventions beat generic presets.

## Skills

Skills describe recurring procedures:

```text
.agents/skills/<skill-name>/
├── SKILL.md
├── references/
└── scripts/
```

`SKILL.md` tells the agent what to do. `references/` contains deeper knowledge the procedure may require. `scripts/` contains reusable supporting tooling.

This repository includes only a few example skills because not every task deserves a skill.

## MCP

`.agents/mcp/` defines desired external capabilities such as GitHub, PostgreSQL, or Supabase access.

The files express vendor-neutral capability intent: purpose, requirement level, expected access scope, configuration notes, and security notes. Actual MCP host configuration may vary between Codex, Claude Code, Cursor, or another coding-agent environment.

Do not commit secrets, tokens, passwords, API keys, or credential values.

## Existing Repositories

When bootstrap is installed into an established codebase, the coding agent should inspect first and ask only unresolved questions.

The agent should identify the actual stack, commands, architecture, conventions, and useful external capabilities from repository evidence. Presets fill gaps or clarify best practice; they do not override project-specific decisions.

## New Repositories

In an empty or nearly empty repository, presets can help establish sensible engineering defaults such as Next.js, Bun, Python with uv, FastAPI, PostgreSQL, Alembic, Docker, GitHub Actions, pre-commit, and feature branches with pull requests.

This project should not become a giant application-template system. When actual application scaffolding is requested, prefer ecosystem-native tooling such as framework generators.

## Agent-Managed And Project Docs

`.agents/*` is operational context for coding agents.

Project `README.md`, user documentation, API docs, and product docs remain normal project documentation. Update them when project behavior genuinely changes, not simply because they are agent-managed.

## Installation

Transparent Git-based installation is preferred.

Linux/macOS:

```sh
git clone git@github.com:ajrlewis/coding-agent-bootstrap.git /tmp/coding-agent-bootstrap
cd /path/to/target/repository
/tmp/coding-agent-bootstrap/install.sh .
```

Windows:

```bat
git clone git@github.com:ajrlewis/coding-agent-bootstrap.git %TEMP%\coding-agent-bootstrap
cd C:\path\to\target\repository
%TEMP%\coding-agent-bootstrap\install.bat .
```

You can also pass the target repository path directly:

```sh
./install.sh /path/to/target/repository
```

```bat
install.bat C:\path\to\target\repository
```

The installer requires the target to be a Git repository and refuses to overwrite `AGENTS.md`, `CLAUDE.md`, or `.agents`.

This project does not currently provide a `curl | sh` installer. The scripts copy files from the bootstrap checkout, so cloning the repository first is the reliable and inspectable method.

## Bootstrap Flow

A first-run coding agent should produce a result like this:

```text
Detected:
✓ Git repository
✓ Next.js
✓ Bun
✓ PostgreSQL
✓ Prisma
✓ GitHub Actions

Inferred:
✓ build/test commands
✓ major source boundaries
✓ migration workflow

Needs maintainer input:
? project goal
? compatibility requirements
? protected architectural areas

Generated:
✓ WORKFLOW.md
✓ COMMANDS.md
✓ ARCHITECTURE.md
✓ selected presets
✓ useful skills
✓ recommended MCP capabilities

Validated:
✓ relevant commands

Removed:
✓ BOOTSTRAP.md
```

The exact output will vary by repository. The important behavior is inspect first, infer what is reliable, ask only unresolved questions, validate commands where practical, and remove setup state after success.

## What This Is Not

This project is not intended to become:

- an agent orchestrator;
- a daemon;
- a task scheduler;
- an application framework;
- a replacement for GitHub Issues, Linear, Jira, or a product backlog;
- a universal project generator;
- a huge prompt library;
- a vendor-specific agent configuration system.

Its job is narrow: establish enough high-quality repository context for coding agents to work safely and effectively.

## Bootstrap Repository vs Installed Result

This repository contains the bootstrap package: installers, the temporary first-run procedure, presets, skills, and MCP capability definitions.

An installed target repository should keep only durable project-relevant context after setup:

```text
AGENTS.md
CLAUDE.md

.agents/
├── VERSION
├── WORKFLOW.md
├── COMMANDS.md
├── ARCHITECTURE.md
├── TODO.md
├── presets/
│   └── only adopted presets
├── skills/
│   └── only useful skills
└── mcp/
    └── only desired capabilities
```

No `.agents/BOOTSTRAP.md` should remain after successful setup.

## Versioning

`.agents/VERSION` contains the bootstrap/schema version that created or last updated the structure.

Version `1` is intentionally simple. It leaves enough information for future migrations without adding a metadata format prematurely.

## Contributing And Extending

Add presets, skills, MCP definitions, or canonical files only when they add durable high-signal context or a reusable procedure without increasing unnecessary cognitive or context load.

Preserve the small conceptual model:

- root instructions route;
- canonical files hold project facts;
- presets hold adopted conventions;
- skills hold procedures;
- MCP files hold desired external capability intent;
- bootstrap setup state is temporary.
