# Database Migration Skill

Use this skill when a task changes persistent schema, seed data, migration tooling, or data-access assumptions.

## Procedure

1. Identify the migration system in use and read the relevant preset.
2. Inspect current schema, models, migrations, and data-access code.
3. Determine whether the change is backward compatible with the deployment model.
4. Generate or write a new migration using the repository's canonical workflow.
5. Inspect generated SQL or migration operations before trusting them.
6. Update application models, generated clients, tests, and docs as needed.
7. Run the relevant migration and test commands from `.agents/COMMANDS.md`.
8. Record unresolved rollout or data-backfill concerns in `.agents/TODO.md`.

Do not edit already-applied migrations unless the maintainer confirms that history is disposable.
