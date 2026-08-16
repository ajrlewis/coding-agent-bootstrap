# GitHub Flow Preset

Use this default when the repository has no documented Git workflow. Existing project-specific policy takes precedence, including an explicitly adopted rebase workflow.

## Branching

- Work on feature or fix branches, not directly on `main`.
- Start each branch from an up-to-date `main`.
- Use a concise, descriptive branch name.
- Keep the branch focused on one logical change.
- Make focused local commits with clear messages.
- Never push directly to `main`.

## Sync Before Push Or PR Updates

Do not sync with `main` before every local commit. Commit locally as needed.

Before pushing the feature branch or opening or updating its pull request, fetch the latest `origin/main` and merge it into the feature branch:

```sh
git fetch origin
git merge origin/main
```

Run these commands while on the feature branch. If conflicts occur:

- resolve them on the feature branch, never directly on `main`;
- inspect the resolved diff carefully;
- rerun the relevant verification from `.agents/COMMANDS.md`;
- do not claim conflict resolution is complete until those checks have run;
- push only after the merge and verification succeed.

Merging `origin/main` is the default because it avoids rewriting shared history, avoids unnecessary force pushes, and is straightforward to audit. Do not replace an existing repository's documented rebase workflow; follow that policy instead.

## Push And Pull Request

After syncing and verifying:

```sh
git push -u origin <branch>
```

Open or update a pull request targeting `main`. Before considering it ready to merge:

- inspect CI and required status checks;
- inspect and address review feedback;
- confirm the branch still merges cleanly where practical;
- address failures instead of bypassing required checks;
- merge through the pull request into protected `main`.

Never force-push a shared branch unless repository policy explicitly permits it and the intent is clear. Never rewrite shared history casually. Prefer reversible, auditable Git operations.

## Recommended Repository Settings

For shared repositories, protect `main` with a GitHub ruleset or branch protection policy. Where appropriate:

- require pull requests before merge;
- require relevant CI or status checks;
- prevent direct pushes to `main`;
- block force pushes and deletion of `main`;
- require approvals when team size or change risk warrants them;
- require branches to be current with `main` before merge when the CI or merge strategy benefits from it.

Apply settings proportionally; not every repository needs every optional restriction.
