# FastAPI Preset

- Keep request and response schemas explicit.
- Put validation at API boundaries and business rules in service/domain code.
- Use dependency injection for shared resources such as settings, database sessions, and auth context.
- Avoid import-time network or database work.
- Keep route handlers thin enough that behavior can be tested without HTTP where practical.
- Document local server, test, and integration commands in `.agents/COMMANDS.md`.
