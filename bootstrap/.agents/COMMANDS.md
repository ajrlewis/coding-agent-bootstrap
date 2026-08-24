# Commands

> Bootstrap state: discover and replace with verified project commands.

Inspect package manifests, project configuration, Makefiles, task runners, CI workflows, Docker configuration, existing documentation, and test configuration.

Identify the tooling required to run the commands the project actually adopts. Record the expected invocation, such as `pnpm supabase` versus a global `supabase`, and any verified runtime or version constraint. Prefer a pinned project dependency or an existing project tool manager over a new global installation. Do not list every optional provider CLI merely because a reusable MCP capability file exists.

Document only applicable commands. Possible sections include install, development, build, lint, format, typecheck or compile, unit tests, integration tests, end-to-end tests, single-test invocation, database, migrations, fast verification, full verification, and release.

For code-bearing repositories, account explicitly for automated behavior verification and relevant static checks. If a category is absent, document the reason or record the unresolved work in `.agents/TODO.md`; do not omit it silently. Documentation, configuration, generated-code, and similar repositories may substitute build, schema, link, integration, or other focused validation where unit tests are not the right fit.

Verify commands where practical before recording them. Never claim a command passed unless it was actually executed. If a relevant check cannot be run, state what was not run and why.

After bootstrap, this file should contain concise target-project commands only; remove this scaffold guidance.
