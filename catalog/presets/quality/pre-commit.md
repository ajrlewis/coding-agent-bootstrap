# pre-commit Preset

- Use pre-commit for fast, repeatable checks that should run before commits.
- Keep hooks aligned with repository formatters, linters, and generated-file policy.
- Avoid slow integration checks as default commit hooks unless the project explicitly chooses that tradeoff.
- Update hook revisions deliberately.
- Run the relevant hooks after changing pre-commit configuration.
- Record the canonical hook command in `.agents/COMMANDS.md`.
