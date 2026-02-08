#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/data/.openclaw/workspace/mikoto-lab-note}"
KEY_PATH="${KEY_PATH:-$REPO_DIR/.deploykey/id_ed25519}"

cd "$REPO_DIR"

# Ensure git safe directory (containers sometimes trip dubious ownership)
git config --global --add safe.directory "$REPO_DIR" >/dev/null 2>&1 || true

# Use deploy key explicitly (avoids picking up other keys)
export GIT_SSH_COMMAND="ssh -i $KEY_PATH -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

git add .
if git diff --cached --quiet; then
  echo "No changes to publish."
  exit 0
fi

git commit -m "Update posts" >/dev/null

git push >/dev/null

echo "Published."