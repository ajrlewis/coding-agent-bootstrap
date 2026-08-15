# Commands

These commands are canonical for this repository.

## Inspect

```sh
rg --files
git status --short --branch
git diff --check
```

## Install To A Target Repository

Linux/macOS:

```sh
./install.sh /path/to/target/repo
```

Windows:

```bat
install.bat C:\path\to\target\repo
```

## Validate

```sh
sh -n install.sh
git diff --check
```

## Full Verification

```sh
sh -n install.sh
git diff --check
```
