#!/usr/bin/env bash
set -euo pipefail

status=0

while IFS= read -r file; do
  [[ -f "$file" ]] || continue
  [[ "$file" == build/* ]] && continue

  if [[ -s "$file" ]] && ! grep -Iq . "$file"; then
    continue
  fi

  matches="$(grep -nE '[[:blank:]]$' "$file" || true)"
  if [[ -n "$matches" ]]; then
    echo "Trailing whitespace in $file:"
    echo "$matches"
    status=1
  fi

  if [[ -s "$file" ]]; then
    last_byte="$(tail -c 1 "$file" | od -An -t x1 | tr -d ' \n')"
    if [[ "$last_byte" != "0a" ]]; then
      echo "Missing final newline: $file"
      status=1
    fi
  fi
done < <({ git ls-files; git ls-files --others --exclude-standard; } | sort -u)

exit "$status"
