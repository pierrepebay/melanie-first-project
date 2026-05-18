#!/usr/bin/env bash
set -euo pipefail

branch="${1:-}"

if [[ -z "$branch" ]]; then
  branch="$(git branch --show-current)"
fi

if [[ -z "$branch" ]]; then
  echo "Could not determine the current branch name"
  exit 2
fi

case "$branch" in
  main|master)
    echo "Skipping protected branch name: $branch"
    exit 0
    ;;
esac

pattern='^[0-9]+-[a-z0-9]+(-[a-z0-9]+)*$'

if [[ ! "$branch" =~ $pattern ]]; then
  echo "Bad branch name: $branch"
  echo "Use: issue-number-issue-title"
  echo "Example: 42-add-diffusion-output"
  exit 1
fi
