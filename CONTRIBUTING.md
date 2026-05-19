# Contributing

This repo is a practice space, but it follows real project habits.

## Before Opening a Pull Request

Run:

```sh
cmake --preset debug
cmake --build --preset debug
ctest --preset debug
scripts/check-whitespace.sh
scripts/check-branch-name.sh 42-add-diffusion-output
scripts/check-commit-message.sh "Add diffusion output #42"
```

## Commit Messages

Use an issue-first subject:

```text
Add new output format #42
Fix empty case name validation #43
Test diffusion edge cells #44
Document CTest usage #45
```

Allowed actions are:

```text
Add, Fix, Update, Remove, Refactor, Document, Test, Build, CI, Chore, Style,
Rename, Improve, Revert
```

The subject must start with one of the allowed actions and end with the GitHub
issue number. Keep the summary short and imperative.

Check a subject locally:

```sh
scripts/check-commit-message.sh "Document CTest usage #45"
```

## Branch Names

Working branches must start with the issue number and use a lowercase,
dash-separated issue title:

```text
42-add-diffusion-output
43-fix-empty-case-name-validation
```

Check a branch name locally:

```sh
scripts/check-branch-name.sh 42-add-diffusion-output
```

## Whitespace

No trailing whitespace. Text files should end with a newline. The CI quality
workflow blocks both issues.

## Optional Local Git Hook

Install local hooks:

```sh
scripts/install-git-hooks.sh
```

This catches weak commit messages before commits and weak branch names before
pushes.
