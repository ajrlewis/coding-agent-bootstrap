# Linear MCP Capability

## Capability

Linear workspace and work-item access.

## Purpose

Useful for reading the current issue description, comments, relationships, project context, assignment, and workflow state, and for linking implementation progress back to the canonical work item.

## Requirement

Optional by default. Required when Linear is the project's canonical work tracker and the current task depends on Linear state that is not available in the repository.

## Source Of Truth

Keep work items in Linear. Do not mirror the Linear backlog or issue descriptions into an agent file. `.agents/TODO.md` remains reserved for durable agent-relevant follow-up work that does not belong in the product backlog.

## Expected Scope

Prefer access limited to the relevant workspace, teams, and projects. Read issue details and discussion as needed. Write status changes, links, or comments only when the adopted project workflow and current task require them. Do not create, delete, reassign, or reprioritize work without clear authorization.

## Configuration

Host-specific MCP or plugin configuration varies. Keep workspace and team selection in the host configuration where practical, and record only non-secret capability intent in this file.

## Security Notes

Do not commit API keys, OAuth tokens, or credential values. Avoid copying sensitive issue content into repository files, command output, or pull-request text unless it is necessary and appropriate for the repository's audience.
