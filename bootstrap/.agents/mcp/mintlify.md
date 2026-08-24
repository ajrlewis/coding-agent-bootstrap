# Mintlify MCP Capability

## Capability

Mintlify documentation search and, when explicitly adopted, authenticated documentation editing.

## Purpose

Useful for searching published project knowledge that is not present locally and for proposing documentation changes through Mintlify's branch-and-pull-request workflow.

## Requirement

Optional by default. Repository-local documentation should be read directly. Use Mintlify access when published or protected knowledge affects the task, or when the project explicitly uses Mintlify's authenticated editing workflow.

## Source Of Truth

For docs-as-code projects, keep documentation source, navigation configuration, and API specifications in the repository. Treat the published Mintlify site as deployed documentation state, not a second editable copy. Do not mirror published pages into agent files.

## Expected Scope

Use the documentation site's `/mcp` endpoint for search-only access to published content. Use the authenticated Mintlify editing MCP at `https://mcp.mintlify.com` only when editing through Mintlify is part of the adopted workflow. Editing access is equivalent to granting a developer commit capability: keep changes on a focused branch, inspect the diff, run relevant documentation checks, and merge through a reviewed pull request.

## Local Tooling

Mintlify's hosted MCP endpoints do not require the `mint` CLI. Adopt `mint` only when the project uses local documentation preview, validation, testing, or authenticated CLI features. It can run through a package runner without a global installation; document the verified form in `.agents/COMMANDS.md`.

## Configuration

Public, partially authenticated, and private documentation require different hosted endpoints and authentication. Confirm that the selected endpoint exposes only the intended audience's content. Keep OAuth sessions and host-specific connector configuration outside the repository.

See the official [documentation MCP guidance](https://www.mintlify.com/docs/ai/model-context-protocol) and [Mintlify editing MCP guidance](https://www.mintlify.com/docs/ai/mintlify-mcp).

## Security Notes

Never expose protected documentation through a public endpoint. Do not enable API operations merely because they appear in an OpenAPI specification; expose only operations intentionally reviewed as safe for agent use. Treat navigation changes, page edits, and generated pull requests as normal repository changes requiring verification.
