#!/usr/bin/env bash
# SessionEnd: writes any project work still unrecorded to today's daily note as raw facts
# (files, commits, pushes, PRs), with no model call, then commits that one file.
. "$(dirname "$0")/lib/vault-state.sh"
input=$(cat)
vault_state_init "$(printf '%s' "$input" | jq -r '.session_id // "default"')"

[ -f "$marker" ] && [ -s "$ledger" ] && [ -d "$vault/daily" ] || { vault_state_clear; exit 0; }

today=$(date '+%Y-%m-%d')
note="$vault/daily/$today.md"
if [ ! -f "$note" ]; then
  printf -- '---\ncreated: %s\nupdated: %s\ntags: [daily]\nsummary: ""\n---\n# %s\n' "$today" "$today" "$today" > "$note"
fi
now=$(date '+%H:%M')
vault_ledger_summary | while IFS= read -r line; do
  printf -- '- %s [auto: unrecorded at session end] %s\n' "$now" "$line" >> "$note"
done

git -C "$vault" add -- "daily/$today.md" >/dev/null 2>&1 \
  && git -C "$vault" commit -q -m "memory: auto-log unrecorded session work" -- "daily/$today.md" >/dev/null 2>&1
vault_state_clear
exit 0
