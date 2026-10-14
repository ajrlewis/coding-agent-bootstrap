# Snowflake Preset

- Keep database, schema, warehouse, role, and environment boundaries explicit; do not rely on an operator's implicit session context.
- Manage durable schema changes as reviewed, versioned code rather than worksheet-only changes.
- Preserve the project's ownership and role hierarchy. Grant least privilege and avoid routine use of broad account-level roles.
- Consider warehouse size, auto-suspend behavior, scan volume, clustering, and data retention when a change can affect cost or performance.
- Review DDL and DML transaction boundaries carefully; do not assume Snowflake handles them like an OLTP database.
- Never commit credentials, private keys, account identifiers containing secrets, or production data extracts.
- For local application tests, use a narrow repository-owned adapter or mock with deterministic synthetic fixtures. Do not present mock behavior as validation of Snowflake SQL, permissions, transactions, or performance.
- Run Snowflake-specific integration checks against an isolated development database, schema, warehouse, and role before promotion.
- Record exact fixture, integration, deployment, and verification commands in `.agents/COMMANDS.md`.
