# coding-agent-bootstrap

`coding-agent-bootstrap` is a temporary kit for making software repositories coding-agent-ready.

It installs a small discovery scaffold, lets a coding agent learn the target project, preserves useful context, and then removes temporary setup state.

```text
install -> preserve existing config if present -> discover -> reconcile -> configure -> validate -> remove bootstrap state
```

## Quick Start

From the root of an existing Git repository, create a focused branch when the repository has commits and is currently on its default branch:

```sh
git switch -c chore/coding-agent-bootstrap
```

Skip that step when already on a feature branch or when the repository has no commits. Then install on Linux or macOS:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh
```

On Windows PowerShell, install after the same branch check:

```powershell
irm https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.ps1 | iex
```

Then start a coding-agent session in the target repository. The agent will see `AGENTS.md` and `.agents/BOOTSTRAP.md`, inspect the project, replace the scaffolds with project-specific context, and remove `BOOTSTRAP.md` when setup is complete.

The default command refuses existing `AGENTS.md`, `CLAUDE.md`, or `.agents/`. For a mature repository, use the explicit [merge workflow](#existing-agent-configuration).

Piping remote code into a shell is convenient but less inspectable. The [transparent clone-based installation](#installation) is the preferred alternative when reviewing the installer first matters.

## Why

Coding agents often enter repositories without knowing the actual development commands, architecture boundaries, project-specific workflow, technology conventions, persistent unfinished context, or external capabilities available to them.

Without explicit project context they repeatedly rediscover facts, make assumptions, introduce unnecessary abstractions, or use incorrect commands. This project establishes a lightweight protocol for durable coding-agent context.

## Design Philosophy

Bootstrap once. Learn the repo. Preserve only useful context. Stay out of the way.

- Inspect before asking and infer before prompting.
- Use existing project conventions before generic defaults.
- Keep `AGENTS.md` short and route detailed context elsewhere.
- Give each fact one natural home; avoid duplicated instructions.
- Make narrow changes and verify relevant outcomes.
- Leave no runtime, service, or hidden persistent state behind.
- Keep canonical intent vendor-neutral.

The installer is intentionally mechanical. The intelligence belongs in the coding agent that runs after installation.

## The Four Rules

Every installed `AGENTS.md` starts with four rules:

1. Think before coding.
2. Keep it simple.
3. Make surgical changes.
4. Work toward verifiable outcomes.

These belong in the root routing file because every agent should see them immediately. Detailed project context belongs in `.agents/`, where it can remain concise and independently maintainable.

## Source And Payload

This repository deliberately has two agent contexts:

```text
Repository root
    configuration for developing coding-agent-bootstrap itself

bootstrap/
    payload installed into target repositories
```

The distinction prevents this project's commands and architecture from leaking into an unrelated target. Root `.agents/ARCHITECTURE.md`, for example, documents the installers and payload boundary. `bootstrap/.agents/ARCHITECTURE.md` instead tells the first agent how to discover and document the target system.

Relevant source tree:

```text
coding-agent-bootstrap/
├── AGENTS.md
├── CLAUDE.md
├── README.md
├── .agents/
│   ├── VERSION
│   ├── WORKFLOW.md
│   ├── COMMANDS.md
│   ├── ARCHITECTURE.md
│   ├── TODO.md
│   ├── presets/
│   ├── skills/
│   └── mcp/
├── bootstrap/
│   ├── AGENTS.md
│   ├── CLAUDE.md
│   └── .agents/
│       ├── VERSION
│       ├── BOOTSTRAP.md
│       ├── WORKFLOW.md
│       ├── COMMANDS.md
│       ├── ARCHITECTURE.md
│       ├── TODO.md
│       ├── presets/
│       ├── skills/
│       └── mcp/
├── tests/
│   └── install.sh
├── install.sh
├── install.ps1
└── install.bat
```

The root keeps only presets, skills, and MCP intent actually adopted by this project. The full reusable library lives in `bootstrap/` because it is discovery material for target repositories.

## Installed Context

The installer copies only the dedicated payload:

```text
target-project/
├── AGENTS.md
├── CLAUDE.md
└── .agents/
    ├── VERSION
    ├── BOOTSTRAP.md
    ├── WORKFLOW.md
    ├── COMMANDS.md
    ├── ARCHITECTURE.md
    ├── TODO.md
    ├── presets/
    ├── skills/
    └── mcp/
```

The root development configuration, README, installers, and tests are never copied.

After setup, `.agents/BOOTSTRAP.md` and any `.coding-agent-bootstrap/` migration state are removed. Only project-relevant presets, skills, and MCP capabilities remain.

## Canonical Context

- `.agents/WORKFLOW.md` describes how development work normally proceeds.
- `.agents/COMMANDS.md` records exact, verified commands, including relevant fast or full verification where useful.
- `.agents/ARCHITECTURE.md` captures the boundaries and relationships needed to make safe changes.
- `.agents/TODO.md` stores persistent agent-relevant deferred work, not the current task plan or product backlog.

During first-run setup these payload files are writing scaffolds. The agent must replace their guidance with concise target-project facts rather than leave generic boilerplate indefinitely.

Each fact should have one natural home:

```text
AGENTS.md       universal behavior and routing
WORKFLOW.md     project development process
COMMANDS.md     exact verified commands
ARCHITECTURE.md project architecture and boundaries
TODO.md         persistent unresolved agent work
presets/        adopted engineering conventions
skills/         reusable task procedures
mcp/            desired external capabilities
```

## Presets

Presets capture adopted engineering opinions. The payload includes concise starting guidance for GitHub Flow, Next.js, Bun, Python, uv, FastAPI, PostgreSQL, Supabase, Alembic, Prisma, Docker, GitHub Actions, and pre-commit.

The name `presets` is intentional. A template suggests copying content blindly. A preset is a starting opinion that must be reconciled with the actual repository.

Existing project conventions take precedence over generic presets. The first agent removes presets that are not relevant and tailors those the target adopts.

The default Git preset uses focused branches, merges the latest `origin/main` into the branch before pushing or updating a PR, and reruns relevant verification after conflict resolution. When GitHub Flow is adopted, the agent-led bootstrap also verifies protection of the remote default branch. Shared repositories require pull requests, at least one approval, administrator enforcement, and blocked force pushes and deletion. Remote settings are changed only with explicit maintainer authorization; unavailable access is recorded as unresolved follow-up work.

## Skills

Skills describe recurring specialized procedures:

```text
.agents/skills/<skill-name>/
├── SKILL.md
├── references/
└── scripts/
```

`SKILL.md` tells the agent what to do, `references/` contains deeper knowledge the procedure may require, and `scripts/` contains reusable supporting tooling. The payload includes only a few examples because routine work does not need a dedicated skill.

## MCP

`.agents/mcp/` expresses desired external capability intent, such as Doppler, GitHub, Linear, Mintlify, PostgreSQL, Supabase, or Vercel access. Each definition describes purpose, requirement level, expected scope, configuration, and security concerns.

When Linear is the canonical work tracker, its issues remain the source of truth rather than being copied into agent files. The adopted workflow can fetch the current item through MCP, move it through real project states, create a typed branch containing the issue identifier, link the pull request, and complete the item after the corresponding work is complete. `.agents/TODO.md` remains for agent-relevant follow-up work, not a mirrored backlog.

External service files follow the same rule: they express access intent rather than duplicate provider state. When adopted, Doppler remains the canonical secret source and may sync values to Vercel or Supabase; repository-owned deployment configuration, migrations, functions, and docs remain versioned locally; Mintlify represents published documentation state. The bootstrap procedure records these relationships in `.agents/ARCHITECTURE.md` and removes capability files the target does not use.

Actual host configuration varies across Codex, Claude Code, Cursor, and other environments. Host-specific integration should remain a thin adapter to canonical intent. Never store credential values in these files.

## Existing Repositories

In an established codebase, the agent inspects manifests, lockfiles, source, tests, CI, task runners, containers, migrations, deployment configuration, documentation, and useful Git history before asking questions.

It preserves intentional project decisions. Presets fill genuine gaps or clarify conventions; they do not impose a preferred stack on every repository.

## Existing Agent Configuration

Default installation remains conservative. If `AGENTS.md`, `CLAUDE.md`, or `.agents/` already exists, the installer lists the conflicting paths and stops without changing them:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh
```

Use explicit merge mode when existing coding-agent configuration should be migrated:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- --merge
```

`--merge` does not text-merge Markdown. It:

1. Copies existing direct conflicts verbatim into `.coding-agent-bootstrap/existing/`.
2. Installs the normal bootstrap payload.
3. Instructs the coding agent to semantically migrate useful project intent into the canonical structure.
4. Leaves cleanup to the coding agent after migration and validation succeed.

The installer preserves only paths it directly replaces: `AGENTS.md`, `CLAUDE.md`, and the complete `.agents/` tree. During discovery, the coding agent also inspects other project guidance, including vendor-specific or custom agent documentation.

Example:

```text
Existing:
AGENTS.md
CLAUDE.md

After install --merge:
AGENTS.md
CLAUDE.md
.agents/
└── BOOTSTRAP.md

.coding-agent-bootstrap/
└── existing/
    ├── AGENTS.md
    └── CLAUDE.md
```

After semantic migration:

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
├── skills/
└── mcp/
```

`.agents/BOOTSTRAP.md` and `.coding-agent-bootstrap/` are then gone. The agent must retain meaningful existing rules, deduplicate compatible guidance, and surface conflicting policies to the maintainer rather than silently choosing one.

The preservation directory is temporary migration input, not a second configuration hierarchy. Do not commit it as the final agent configuration.

## New Repositories

In an empty or nearly empty Git repository, presets can help the maintainer and agent establish sensible engineering defaults. When application scaffolding is requested, use ecosystem-native generators rather than turning this project into a universal application-template system.

The installer currently requires an existing Git repository. It does not silently run `git init`.

## Agent-Managed And Project Docs

`.agents/*` is agent-maintained operational context. Humans may edit it, and agents are expected to keep it accurate when their work changes the facts it describes.

Project `README.md`, user documentation, API docs, and product docs remain normal project documentation. Update them when project behavior changes, not merely because agent context exists.

## Prerequisites And Optional Tooling

The installer has a deliberately small runtime boundary:

- an existing Git repository and the `git` executable;
- a POSIX `sh` environment for `install.sh`, or PowerShell for `install.ps1`;
- `curl` only when using the POSIX remote one-liner. PowerShell's remote form uses `Invoke-RestMethod` through `irm`.

Homebrew, Node.js, Codex, `gh`, and provider CLIs are not installer dependencies. The first-run agent discovers which target-project workflows are actually adopted, verifies the corresponding commands, and records missing required tooling without installing global software or changing user-level MCP configuration.

Common optional tools have different boundaries:

| Capability | Provider CLI required for MCP? | Adopt local tooling when |
| --- | --- | --- |
| GitHub | No | `gh` is used for pull requests, branch protection, releases, or API operations. |
| Linear | No | Its hosted remote MCP connection is sufficient; compatibility wrappers may require Node.js. |
| Doppler | Its local MCP server requires Node.js and `npx`, not the Doppler CLI. | Project commands inject secrets with `doppler run` or otherwise use the CLI. |
| Vercel | No | Project commands use local environment retrieval, builds, logs, or deployments. |
| Supabase | No | Local development, migrations, type generation, or the local stack is adopted; the local stack also needs a container runtime. |
| Mintlify | No | Local documentation preview, validation, or testing is adopted. |

Examples for an adopted macOS workflow are intentionally separate from installation:

```sh
brew install gh
brew install gnupg dopplerhq/cli/doppler
pnpm i -g vercel
pnpm add -D supabase
npx mint dev
```

Prefer a repository-pinned dependency such as Supabase's project package when supported. Keep exact, verified invocations in the target's `.agents/COMMANDS.md`; do not retain unused provider tooling merely because its capability template was installed.

## Installation

All installation modes require a Git repository. In repositories with commits, installers refuse to modify the default branch; create a focused branch first, or use the explicit `--allow-current-branch` (`-AllowCurrentBranch` in PowerShell) override when installation there is intentional. Unborn repositories are allowed. By default installers also refuse existing direct conflicts; explicit merge mode preserves those paths before replacement. Installers stage the payload and preserved state first, clean temporary downloads, modify no unrelated files, and install no global software.

### Shell: Remote

Run from the target repository root:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh
```

The streamed script shallow-clones the bootstrap repository into a temporary directory, copies only `bootstrap/`, and removes the temporary checkout.

For merge mode:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- --merge
```

To intentionally install on the current default branch:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- --allow-current-branch
```

### Shell: Inspectable Clone

```sh
bootstrap_dir="$(mktemp -d)"
git clone --depth 1 https://github.com/ajrlewis/coding-agent-bootstrap.git "$bootstrap_dir"
cd /path/to/target/repository
"$bootstrap_dir/install.sh"
rm -rf "$bootstrap_dir"
```

A local checkout can also target a repository explicitly:

```sh
./install.sh /path/to/target/repository
```

Add `--merge` to preserve existing direct conflicts:

```sh
./install.sh --merge /path/to/target/repository
```

Add `--allow-current-branch` only when installing on the repository's default branch is intentional.

### Windows: Remote PowerShell

Run from the target repository root:

```powershell
irm https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.ps1 | iex
```

The PowerShell installer uses the same temporary shallow-clone and overwrite-refusal model as the shell installer.

For remote merge mode, invoke the downloaded script block with `-Merge`:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.ps1))) -Merge
```

Use `-AllowCurrentBranch` only when installing on the repository's default branch is intentional.

### Windows: Inspectable Clone

```powershell
$bootstrapDir = Join-Path ([System.IO.Path]::GetTempPath()) ("coding-agent-bootstrap-" + [guid]::NewGuid().ToString("N"))
git clone --depth 1 https://github.com/ajrlewis/coding-agent-bootstrap.git $bootstrapDir
Set-Location C:\path\to\target\repository
& "$bootstrapDir\install.ps1"
Remove-Item -Recurse -Force $bootstrapDir
```

`install.bat` remains a local compatibility wrapper around `install.ps1`:

```bat
install.bat C:\path\to\target\repository
```

Local Windows merge forms are:

```powershell
.\install.ps1 -Merge C:\path\to\target\repository
```

```bat
install.bat -Merge C:\path\to\target\repository
```

## Bootstrap Flow

A first-run coding agent should:

1. Inspect the target repository before asking questions.
2. Distinguish discovered facts, maintainer-declared facts, and derived conclusions.
3. Read `.coding-agent-bootstrap/existing/` when merge state is present and inspect other existing agent guidance.
4. Discover the stack, commands, architecture, workflow, conventions, useful skills, and desired external capabilities.
5. Reconcile compatible existing intent, deduplicate it, and surface meaningful policy conflicts.
6. When GitHub Flow is adopted, detect the remote default branch and verify its protection, changing remote settings only with explicit maintainer authorization.
7. When an external tracker is adopted, keep it canonical and document its work-item-to-branch-to-pull-request lifecycle without mirroring the backlog.
8. For adopted hosted services, document canonical state, sync direction, environment boundaries, and authorization requirements without duplicating credentials or provider state.
9. Verify only the command-line tools and host capabilities required by adopted workflows; do not install global tools or connect external accounts implicitly.
10. Reconcile an appropriate quality baseline, treating absent tests or static checks as an explicit decision rather than an implicit exemption.
11. Ask only for constraints or conflicts that cannot be reliably resolved.
12. Rewrite the canonical scaffold files as concise target-specific context.
13. Validate documented commands where practical and report anything that could not be run.
14. Remove duplicated guidance and unselected presets, skills, or MCP definitions.
15. Remove `.agents/BOOTSTRAP.md` and `.coding-agent-bootstrap/` only when setup and migration are genuinely complete.

For code-bearing repositories, bootstrap checks for automated behavior verification and relevant static analysis. It does not blindly require unit tests: documentation, configuration, generated-code, and other specialized projects may need build, schema, link, integration, or similar validation instead. Adding dependencies, configuration, tests, or CI remains an explicit maintainer decision, and intentionally absent or blocked checks are recorded rather than silently ignored.

Never claim a check passed unless it was actually run. Relevant verification comes from the target's `.agents/COMMANDS.md`; bootstrap does not hard-code every possible check for every task.

## Vendor Compatibility

`AGENTS.md` and `.agents/*` are canonical. `CLAUDE.md` is deliberately only a small pointer back to `AGENTS.md`. Additional vendor-specific files should be added only for a concrete compatibility requirement, not as duplicate instruction sets.

## Versioning

The two version files have separate scopes:

- Root `.agents/VERSION` identifies the schema used by this repository's own agent context.
- `bootstrap/.agents/VERSION` identifies the installable payload schema and becomes the target's `.agents/VERSION`.

Payload version `3` adds explicit preservation state and semantic migration instructions for existing coding-agent configuration. Versioning remains intentionally simple; there is no migration framework.

## What This Is Not

This project is not an agent orchestrator, daemon, task scheduler, application framework, product-backlog replacement, universal project generator, huge prompt library, or vendor-specific configuration system.

Its job is narrow: establish enough high-quality repository context for coding agents to work safely and effectively.

## Contributing And Extending

Add a canonical file, preset, skill, or MCP definition only when it contributes durable high-signal context or a reusable procedure without unnecessary cognitive or context load.

Preserve the small model: root instructions route, canonical files hold project facts, presets hold adopted conventions, skills hold procedures, MCP files hold capability intent, and bootstrap setup state is temporary.
