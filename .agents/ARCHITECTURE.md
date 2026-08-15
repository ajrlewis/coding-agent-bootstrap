# Architecture

`coding-agent-bootstrap` is a static bootstrap kit.

## Components

- `AGENTS.md` is the concise canonical entrypoint for coding agents.
- `.agents/*.md` stores durable project-specific agent context.
- `.agents/presets/` stores reusable engineering conventions that may be adopted and tailored by a target repository.
- `.agents/skills/` stores recurring procedures where consistent execution matters.
- `.agents/mcp/` stores vendor-neutral desired external capability definitions.
- `install.sh`, `install.bat`, and `install.ps1` copy the bootstrap files into a target repository.

## Boundaries

- The installer is intentionally dumb. It copies files safely and refuses existing agent configuration.
- Repository inspection, inference, tailoring, validation, and cleanup are performed by the coding agent after installation.
- No runtime service, daemon, orchestration layer, or application generator belongs here.
- Host-specific files must be thin adapters that point back to canonical context.

## Invariants

- `AGENTS.md` stays short and routes to deeper context.
- Commands live in `.agents/COMMANDS.md`, not scattered through presets and skills.
- `.agents/BOOTSTRAP.md` is temporary setup state and should be removed after first-run configuration.
- Installed target repositories should keep only adopted presets, useful skills, and desired MCP capabilities.
