# GitHub Flow

This repository uses focused branches and pull requests into `main`.

- Start concise feature or fix branches from the latest `main`; never push directly to `main`.
- Keep each branch and commit focused on one coherent change.
- Commit locally as needed. Do not merge `main` before every commit.
- Before pushing or opening or updating a PR, run `git fetch origin` and merge `origin/main` into the feature branch.
- Resolve conflicts on the feature branch, inspect the resolved diff, and rerun relevant checks from `.agents/COMMANDS.md` before pushing.
- Prefer merge over rebase so shared history is not rewritten and force pushes are unnecessary.
- Push the feature branch and open or update a pull request targeting `main`.
- Inspect CI, required checks, mergeability, and review feedback before considering the change ready.
- Never bypass required checks, rewrite shared history casually, or force-push a shared branch without explicit policy and clear intent.

Protect `main` with a GitHub rule that requires pull requests, applies to administrators, and blocks direct pushes, force pushes, and deletion. This solo-maintainer repository does not require an approving review because pull request authors cannot approve their own changes. Add required checks or an up-to-date branch requirement when the repository's CI and merge strategy warrant them.
