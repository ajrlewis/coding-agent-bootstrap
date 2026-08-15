# uv Preset

- Use `uv` when the repository has adopted `pyproject.toml` plus `uv.lock` or maintainer direction.
- Prefer `uv sync` for environment setup.
- Use `uv run <command>` for project commands that need the managed environment.
- Keep `uv.lock` updated when dependencies change.
- Do not mix dependency managers without an explicit project decision.
- Document verified install, test, lint, typecheck, and migration commands in `.agents/COMMANDS.md`.
