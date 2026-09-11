# Azure Bicep Preset

- Keep reusable resource definitions in modules and keep environment differences in `.bicepparam` files rather than branching the infrastructure implementation.
- Preserve the repository's environment layout. Common forms include `dev.bicepparam`, `uat.bicepparam`, and `prod.bicepparam`, or `dev/`, `uat/`, and `prod/` directories that each contain `main.bicepparam`.
- Make deployment scope, subscription, resource group, location, naming, tags, and dependencies explicit.
- Use reviewed resource API versions and avoid unrelated resource churn in generated deployment plans.
- Do not store secrets in parameter files or outputs. Reference the project's approved secret source and use secure parameters where values must cross the deployment boundary.
- Run the repository's Bicep format, lint, build, validation, and what-if checks before deployment when available. Treat what-if as a review aid, not proof that deployment will succeed.
- Record exact commands and the intended `dev` to `uat` to `prod` promotion path in `.agents/COMMANDS.md` and `.agents/WORKFLOW.md`.
