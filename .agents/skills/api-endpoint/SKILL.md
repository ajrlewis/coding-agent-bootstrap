# API Endpoint Skill

Use this skill when adding or changing an HTTP, RPC, webhook, or public service endpoint.

## Procedure

1. Identify the existing API framework, routing conventions, auth model, validation layer, and error format.
2. Preserve established request and response patterns.
3. Validate input at the boundary and keep business logic in the appropriate service/domain layer.
4. Update tests for success, validation failure, auth/permission behavior, and important edge cases.
5. Update API docs or generated schemas when endpoint behavior changes.
6. Run focused tests plus relevant lint/typecheck commands from `.agents/COMMANDS.md`.
7. Record unresolved compatibility or rollout concerns in `.agents/TODO.md`.
