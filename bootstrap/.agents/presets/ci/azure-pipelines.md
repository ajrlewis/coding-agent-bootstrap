# Azure Pipelines Preset

- Keep CI validation separate from deployment stages, with explicit dependencies and conditions between stages.
- Build once and promote the same reviewed artifact through `dev`, `uat`, and `prod`; do not rebuild environment-specific variants unless the architecture requires it.
- Prefer a visible staged lifecycle: build and test, deploy to `dev`, verify `dev`, obtain human approval for `uat`, deploy to `uat`, verify `uat`, obtain human approval for `prod`, deploy to `prod`, then verify `prod`. Tailor stage names and verification to the repository rather than adding empty ceremonial stages.
- Use Azure Pipelines environments and deployment jobs when the project relies on deployment history, approvals, or exclusive locks. Preserve checks configured outside YAML and never imply that a YAML change alone updates them.
- Keep environment deployment out of pull-request validation. Let successful validation flow into `dev` without human approval; put human gates immediately before `uat` and `prod`, while preserving any stronger existing controls.
- Scope service connections, variable groups, and permissions per environment with least privilege. Retrieve secrets from the approved secret store and never echo them.
- Use small templates for genuinely repeated stage or job structure, while keeping the pipeline flow readable and avoiding speculative indirection.
- For Bicep deployments, validate and review what-if output before deployment, then verify the deployed resources and surface partial failures clearly.
- Give every verification stage concrete health, smoke, integration, or deployment checks with a clear failure signal. Keep triggers, branch filters, artifact flow, deployment commands, and rollback or recovery steps aligned with `.agents/WORKFLOW.md` and `.agents/COMMANDS.md`.
