# SQL Server Preset

- Treat schema changes as versioned deployment scripts or migrations, not ad hoc edits in a shared database.
- Preserve the repository's migration tool, ordering rules, and rollback policy. Make transaction boundaries explicit and verify how DDL and data migrations behave on the supported SQL Server version.
- Schema-qualify object names and choose column types, nullability, constraints, and indexes deliberately.
- Inspect compatibility level, collation, isolation level, locking, and data volume before changing queries or schema. Do not add locking hints such as `NOLOCK` by default.
- Parameterize application queries and keep credentials and complete connection strings out of the repository.
- Prefer a disposable SQL Server instance for local integration tests when the host supports it; a lightweight mock must not be treated as proof of SQL Server-specific behavior.
- Seed local and test databases with small, deterministic, synthetic datasets through a repeatable command. Keep schema migration separate from optional sample data.
- Validate changes locally and against an isolated development database before promotion, and record exact setup, migration, seed, reset, and verification commands in `.agents/COMMANDS.md`.
