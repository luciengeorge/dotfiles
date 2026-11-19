#!/usr/bin/env bash
# PostToolUse (Write|Edit|Bash): tracks whether this session's project work has
# been recorded in the Obsidian vault. Paired with vault-stop.sh.
#   - edit a file inside a git repo that is NOT the vault -> mark session dirty
#   - write any file inside the vault                     -> clear the marker
#
# Bash was added because appending to a daily note with a heredoc and committing is
# the natural way to write this vault, and the file_path-only version could not see
# it: the entry was written and committed while the marker stayed set, so Stop kept
# blocking work that had in fact been recorded.
#
# Bash is detected by MTIME, not by parsing the command. A command that merely READS
# the vault (grep, cat, ls, git log) must not clear the marker, and no amount of
# string matching on the command reliably separates a read from a write. Comparing
# mtimes against the marker asks the only question that matters: did a file under the
# vault actually change?
input=$(cat)
vault="/Users/lucien/obsidian"
sid=$(printf '%s' "$input" | jq -r '.session_id // "default"')
marker="/tmp/claude-vault-dirty-${sid}"

f=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

if [ -n "$f" ]; then
  # Write / Edit: decide from the path.
  case "$f" in
    "$vault"/*)
      rm -f "$marker"
      ;;
    *)
      top=$(git -C "$(dirname "$f")" rev-parse --show-toplevel 2>/dev/null)
      if [ -n "$top" ] && [ "$top" != "$vault" ]; then
        : > "$marker"
      fi
      ;;
  esac
  exit 0
fi

# Bash (no file_path). Only ever CLEARS, never marks dirty: a shell command is not
# reliable evidence that project files were edited, and Write/Edit already covers that.
[ -f "$marker" ] || exit 0
[ -d "$vault" ] || exit 0

# Any file under the vault newer than the marker means a real write happened.
# .git is pruned so that a commit alone does not count as recording the work.
changed=$(find "$vault" -name .git -prune -o -type f -newer "$marker" -print -quit 2>/dev/null)
[ -n "$changed" ] && rm -f "$marker"

exit 0
