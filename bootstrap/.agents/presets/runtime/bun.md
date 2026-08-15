# Bun Preset

- Use Bun when the repository has selected it through `bun.lock`, `bunfig.toml`, package scripts, or maintainer direction.
- Prefer `bun install` for dependency installation in Bun-managed projects.
- Keep package-manager lockfiles consistent; do not introduce npm, pnpm, or Yarn lockfiles unless the project adopts them.
- Use package scripts as the command interface when available.
- Record verified commands in `.agents/COMMANDS.md`.
