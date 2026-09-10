# Azure DevOps Git Preset

Use this preset for repositories hosted in Azure Repos when no more specific Git policy exists. Existing project policy takes precedence. The `az repos` examples apply to Azure DevOps Services; Azure DevOps Server does not support the Azure DevOps CLI commands.

## Branching

- Work on focused feature or fix branches, not directly on the remote default branch.
- Detect the remote default branch instead of assuming it is named `main`.
- Start from an up-to-date default branch and use a concise, descriptive branch name.
- Include the Azure Boards work-item ID when the project convention requires it.
- Keep commits focused and never rewrite shared history casually.

Before pushing or opening or updating a pull request, fetch the remote default branch and merge it into the feature branch:

```sh
git fetch origin
git merge origin/<default-branch>
```

Resolve conflicts on the feature branch, inspect the result, and rerun relevant checks from `.agents/COMMANDS.md` before pushing. Preserve an established rebase policy when the repository already has one.

## Azure CLI

The Azure DevOps commands require Azure CLI 2.30.0 or later and the `azure-devops` extension. Verify existing tooling before use:

```sh
az --version
az extension show --name azure-devops
az devops configure --list
```

Do not install or update the CLI or extension without maintainer authorization. For Azure DevOps Services, configure reusable defaults when appropriate:

```sh
az devops configure --defaults organization=https://dev.azure.com/<organization> project=<project>
az repos show --repository <repository> --output table
```

Keep credentials out of the repository and prefer Microsoft Entra authentication over personal access tokens where the environment supports it.

`az repos show` reports a fully qualified default branch such as `refs/heads/main`. Use the short form, such as `main`, for the `<default-branch>` placeholders below.

## Push And Pull Request

After syncing and verification:

```sh
git push -u origin <branch>
az repos pr create --repository <repository> --source-branch <branch> --target-branch <default-branch> --title "<title>" --description "<description>"
```

When applicable, add `--work-items <id>` to link canonical Azure Boards work. Inspect the pull request and its policy evaluations before considering it ready:

```sh
az repos pr show --id <pull-request-id>
az repos pr policy list --id <pull-request-id> --output table
az repos pr reviewer list --id <pull-request-id> --output table
```

Do not use `--bypass-policy` unless repository policy explicitly permits it and the maintainer authorizes that specific bypass.

## Default Branch Protection

Protect the actual remote default branch, normally `main`, with Azure Repos branch policies and branch security:

- require pull requests through blocking branch policies and do not grant ordinary contributors `Bypass policies when pushing`;
- do not grant ordinary contributors `Force push`, which also controls branch deletion;
- require at least one approving reviewer for shared repositories;
- do not count the pull-request creator's vote unless project policy explicitly allows it;
- require comment resolution and successful build validation when relevant pipelines exist;
- restrict policy bypass permissions to explicitly authorized administrators.

Resolve the repository ID and inspect effective policies without changing them:

```sh
az repos show --repository <repository> --query '{id:id,defaultBranch:defaultBranch}' --output table
az repos policy list --repository-id <repository-id> --branch <default-branch> --output table
```

An authorized maintainer can create a minimum-approver policy with:

```sh
az repos policy approver-count create --allow-downvotes false --blocking true --branch <default-branch> --creator-vote-counts false --enabled true --minimum-approver-count 1 --repository-id <repository-id> --reset-on-source-push true
```

Branch policies prevent ordinary direct pushes only when contributors lack `Bypass policies when pushing`. Verify branch security in **Project settings > Repositories > Security** for the default branch, especially `Bypass policies when pushing`, `Bypass policies when completing pull requests`, `Force push`, `Edit policies`, and `Manage permissions`. Preserve the normal `Contribute` access needed by the adopted pull-request workflow. Obtain explicit maintainer authorization before changing remote policies or permissions, then verify the effective result. If authentication, administration permission, or suitable tooling is unavailable, record the unresolved work in `.agents/todos/TODO.md` and do not claim protection is configured.
