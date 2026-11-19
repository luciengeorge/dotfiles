#!/usr/bin/env bash
# Stop: asks for a vault entry only at natural points, so small turns don't each cost an
# extra model turn: after a commit, push or PR, or once project work has gone unrecorded
# for VAULT_STOP_AFTER_SECS. Whatever is still unrecorded when the session ends is written
# by vault-session-end.sh.
. "$(dirname "$0")/lib/vault-state.sh"
input=$(cat)
vault_state_init "$(printf '%s' "$input" | jq -r '.session_id // "default"')"
active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
after="${VAULT_STOP_AFTER_SECS:-2700}"

[ "$active" = "true" ] && exit 0
[ -f "$marker" ] || exit 0
[ -f "$since" ] || : > "$since"

due=""
[ -f "$milestone" ] && due="a commit, push or PR"
if [ -z "$due" ] && [ -f "$since" ]; then
  age=$(( $(date +%s) - $(stat -f %m "$since") ))
  [ "$age" -ge "$after" ] && due="$(( age / 60 )) minutes of unrecorded work"
fi
[ -n "$due" ] || exit 0

summary=$(vault_ledger_summary)
jq -n --arg due "$due" --arg summary "$summary" '{decision:"block",reason:(
  "Record this session'"'"'s project work in the Obsidian vault (" + $due + " since the last entry). Follow /Users/lucien/obsidian/AGENTS.md: append timestamped bullets to today'"'"'s daily/YYYY-MM-DD.md (create it if missing), update projects/<slug>/index.md if this maps to a tracked project, then commit in the vault. Say what was done and why, not just file names; use the real times below.\n\nUnrecorded since the last entry (time, repo@branch):\n" + $summary +
  "\n\nWriting any file under /Users/lucien/obsidian clears this check.")}'
exit 0
