#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
mkdir -p "$repo_root/.git/hooks"

cat > "$repo_root/.git/hooks/commit-msg" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
"$repo_root/scripts/check-commit-message.sh" "$1"
HOOK

cat > "$repo_root/.git/hooks/pre-push" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
"$repo_root/scripts/check-branch-name.sh"
HOOK

chmod +x "$repo_root/.git/hooks/commit-msg"
chmod +x "$repo_root/.git/hooks/pre-push"
echo "Installed .git/hooks/commit-msg and .git/hooks/pre-push"
