#!/usr/bin/env bash
set -euo pipefail

pattern='^#[0-9]+: (Add|Fix|Update|Remove|Refactor|Document|Test|Build|CI|Chore|Style|Rename|Improve|Revert) .{1,72}$'

check_subject() {
  local subject="$1"

  if [[ "$subject" =~ ^Merge[[:space:]] ]]; then
    return 0
  fi

  if [[ ! "$subject" =~ $pattern ]]; then
    echo "Bad commit message: $subject"
    echo "Use: #issue_number: Action short imperative summary"
    echo "Example: #42: Fix unstable time step validation"
    return 1
  fi
}

if [[ "${1:-}" == "--range" ]]; then
  range="${2:-}"
  if [[ -z "$range" ]]; then
    echo "Usage: $0 --range <git-range>"
    exit 2
  fi

  status=0
  while IFS= read -r subject; do
    check_subject "$subject" || status=1
  done < <(git log --format=%s "$range")
  exit "$status"
fi

if [[ $# -gt 0 && -f "$1" ]]; then
  subject="$(head -n 1 "$1")"
elif [[ $# -gt 0 ]]; then
  subject="$*"
else
  subject="$(git log -1 --format=%s)"
fi

check_subject "$subject"
