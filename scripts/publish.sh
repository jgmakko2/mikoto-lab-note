#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/data/.openclaw/workspace/mikoto-lab-note}"

# Prefer OpenClaw-managed deploy key (works in this runtime) and fall back to repo-local deploykey.
DEFAULT_KEY_OPENCLAW="/data/.openclaw/ssh/mikoto_lab_note_deploy"
DEFAULT_KEY_REPO="$REPO_DIR/.deploykey/id_ed25519"
KEY_PATH="${KEY_PATH:-$DEFAULT_KEY_OPENCLAW}"
if [[ ! -f "$KEY_PATH" ]]; then
  KEY_PATH="$DEFAULT_KEY_REPO"
fi

KNOWN_HOSTS_PATH="$REPO_DIR/.ssh-tmp/known_hosts"

cd "$REPO_DIR"

# Ensure git safe directory (containers sometimes trip dubious ownership)
git config --global --add safe.directory "$REPO_DIR" >/dev/null 2>&1 || true

# Use deploy key explicitly (avoids picking up other keys)
# Avoid /data/.ssh/known_hosts (not readable in this runtime) by using repo-local known_hosts.
mkdir -p "$(dirname "$KNOWN_HOSTS_PATH")"
export GIT_SSH_COMMAND="ssh -i $KEY_PATH -o IdentitiesOnly=yes -o UserKnownHostsFile=$KNOWN_HOSTS_PATH -o GlobalKnownHostsFile=/dev/null -o StrictHostKeyChecking=accept-new"

git add .
if git diff --cached --quiet; then
  echo "No changes to publish."
  exit 0
fi

git commit -m "Update posts" >/dev/null

git push >/dev/null

echo "Published."