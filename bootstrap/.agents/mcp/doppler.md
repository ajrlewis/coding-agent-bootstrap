# Doppler MCP Capability

## Capability

Doppler project, configuration, and secret-management access.

## Purpose

Useful for confirming project and configuration metadata, inspecting secret names and activity, and supplying runtime secrets to approved development commands without storing values in the repository.

## Requirement

Optional by default. Required when Doppler is the project's canonical secret manager and the current task depends on secret metadata or runtime injection that is not available through the existing development environment.

## Source Of Truth

Keep secret values in Doppler. Repository files may document required variable names and their purpose, but must not mirror values. When Doppler syncs secrets to Vercel, Supabase, CI, or another destination, change the canonical Doppler configuration rather than creating an unmanaged second source of truth.

## Expected Scope

Use the narrowest token, project, configuration, and environment scope that supports the task. Prefer the official MCP server's read-only mode for inspection and restrict it to the relevant project and config. Development access does not imply staging or production access. Creating or changing secrets, environments, configs, syncs, service tokens, or production values requires explicit authorization.

## Local Tooling

Doppler's local MCP server runs through Node.js and `npx`; verify its current runtime requirement before configuration. The separate `doppler` CLI is recommended only when adopted project commands use runtime injection such as `doppler run`. Neither tool is an installer prerequisite, and neither should be installed globally without authorization.

## Configuration

Prefer Doppler's official MCP server when the project adopts it, and verify its current maturity and available operations before relying on it. Keep host-specific setup and authentication outside the repository, and enforce access with properly scoped Doppler credentials rather than relying only on client flags. Prefer runtime injection such as `doppler run` over downloading persistent secret files. Record exact verified project commands in `.agents/COMMANDS.md`.

See the official [Doppler MCP documentation](https://docs.doppler.com/docs/mcp) and [integration documentation](https://docs.doppler.com/docs/integrations).

## Security Notes

Never commit, print, log, summarize, or paste secret values, CLI tokens, service tokens, downloaded configs, or credentials. Avoid commands that reveal complete environments. If a tool returns a value unexpectedly, do not repeat it in chat, commits, issues, pull requests, or agent-managed context.
