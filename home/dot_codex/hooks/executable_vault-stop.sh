#!/usr/bin/env bash
# Stop: blocks finishing if this session edited project files but never recorded
# the work in the Obsidian vault. Cleared by writing to the vault (vault-mark.sh).
input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // "default"')
active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
marker="/tmp/claude-vault-dirty-${sid}"

# Safety valve: if we already blocked once this stop cycle, don't loop forever.
[ "$active" = "true" ] && exit 0

if [ -f "$marker" ]; then
  cat <<'JSON'
{"decision":"block","reason":"Project files were edited this session but the work was not recorded in the Obsidian vault. Follow /Users/lucien/obsidian/AGENTS.md: append a timestamped bullet to today's daily/YYYY-MM-DD.md (create it if missing), update projects/<slug>/index.md if this maps to a tracked project, then commit in the vault. Writing any file under /Users/lucien/obsidian clears this check."}
JSON
fi
exit 0
