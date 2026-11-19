#!/usr/bin/env bash
# PostToolUse (Write|Edit|Bash): keeps a per-session ledger of unrecorded project work
# for vault-stop.sh and vault-session-end.sh. See lib/vault-state.sh for the files.
#   - Write/Edit inside a non-vault git repo -> ledger "edit"
#   - Bash git commit / git push / gh pr create in a non-vault repo -> ledger milestone
#   - any write under the vault -> clear everything
#
# Bash clears by MTIME, not by parsing the command: a command that only READS the vault
# (grep, cat, git log) must not clear, and string matching cannot tell a read from a
# write. A vault file newer than the marker means a real write happened. .git is pruned
# so a vault commit alone does not count.
. "$(dirname "$0")/lib/vault-state.sh"
input=$(cat)
vault_state_init "$(printf '%s' "$input" | jq -r '.session_id // "default"')"

f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

if [ -n "$f" ]; then
  case "$f" in
    "$vault"/*) vault_state_clear ;;
    *)
      info=$(vault_repo_of "$(dirname "$f")")
      if [ -n "$info" ]; then
        IFS=$'\t' read -r repo branch top <<<"$info"
        vault_record edit "$repo" "$branch" "${f#"$top"/}"
      fi
      ;;
  esac
  exit 0
fi

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
[ -n "$cmd" ] || exit 0
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')

if printf '%s' "$cmd" | grep -qE '(^|[;&|[:space:]])(git|gh)[[:space:]]'; then
  # Where the command ran: an explicit `git -C <dir>`, else a leading `cd <dir> &&`, else cwd.
  dir=$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+-C[[:space:]]+("([^"]+)"|([^[:space:]]+)).*/\2\3/p' | head -1)
  [ -n "$dir" ] || dir=$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+("([^"]+)"|([^[:space:];&]+)).*/\2\3/p' | head -1)
  dir="${dir/#\~/$HOME}"
  case "$dir" in /*) ;; "") dir="$cwd" ;; *) dir="$cwd/$dir" ;; esac
  info=$(vault_repo_of "$dir")
  if [ -n "$info" ]; then
    IFS=$'\t' read -r repo branch top <<<"$info"
    out=$(printf '%s' "$input" | jq -r '[.tool_response.stdout?, .tool_response.stderr?, (.tool_response|strings)] | map(select(.)) | join("\n")' 2>/dev/null)
    if printf '%s' "$cmd" | grep -qE 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit'; then
      # Only count a commit that actually landed in the last two minutes.
      ct=$(git -C "$dir" log -1 --format=%ct 2>/dev/null)
      if [ -n "$ct" ] && [ $(( $(date +%s) - ct )) -le 120 ]; then
        vault_record commit "$repo" "$branch" "$(git -C "$dir" log -1 --format='%h %s')"
      fi
    fi
    if printf '%s' "$cmd" | grep -qE 'git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push' \
       && ! printf '%s' "$out" | grep -qiE 'rejected|fatal:|error:'; then
      vault_record push "$repo" "$branch" "$branch"
    fi
    if printf '%s' "$cmd" | grep -qE 'gh[[:space:]]+pr[[:space:]]+create'; then
      url=$(printf '%s' "$out" | grep -oE 'https://github.com/[^[:space:]]+/pull/[0-9]+' | head -1)
      [ -n "$url" ] && vault_record pr "$repo" "$branch" "$url"
    fi
  fi
fi

[ -f "$marker" ] || exit 0
[ -d "$vault" ] || exit 0
changed=$(find "$vault" -name .git -prune -o -type f -newer "$marker" -print -quit 2>/dev/null)
[ -n "$changed" ] && vault_state_clear

exit 0
