# Shared state for the vault hooks (vault-mark, vault-stop, vault-session-end).
# Per session, under /tmp:
#   claude-vault-dirty-<sid>      exists while project work is unrecorded; mtime = last project change
#   claude-vault-since-<sid>      created at the first unrecorded change; mtime drives the time fallback
#   claude-vault-milestone-<sid>  a commit, push or PR happened since the last vault write
#   claude-vault-ledger-<sid>     TSV: HH:MM, kind (edit|commit|push|pr), repo, branch, detail
vault="${VAULT_DIR:-/Users/lucien/obsidian}"
vault_state_init() {
  sid="$1"
  marker="/tmp/claude-vault-dirty-${sid}"
  since="/tmp/claude-vault-since-${sid}"
  milestone="/tmp/claude-vault-milestone-${sid}"
  ledger="/tmp/claude-vault-ledger-${sid}"
}

vault_state_clear() {
  rm -f "$marker" "$since" "$milestone" "$ledger"
}

# Prints "<repo>\t<branch>" for a directory inside a non-vault git repo, nothing otherwise.
# A linked worktree reports its main repo's name, so t3 worktrees read as "web-app".
vault_repo_of() {
  local dir="$1" top common
  top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || return 0
  [ "$top" = "$vault" ] && return 0
  common=$(cd "$dir" && cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd)
  printf '%s\t%s\t%s\n' "$(basename "$(dirname "$common")")" "$(git -C "$dir" branch --show-current 2>/dev/null)" "$top"
}

vault_record() {
  local kind="$1" repo="$2" branch="$3" detail="$4"
  [ "$kind" = edit ] && [ -f "$ledger" ] && grep -qF "	edit	${repo}	${branch}	${detail}" "$ledger" && { : > "$marker"; return 0; }
  printf '%s\t%s\t%s\t%s\t%s\n' "$(date '+%H:%M')" "$kind" "$repo" "$branch" "$detail" >> "$ledger"
  : > "$marker"
  [ -f "$since" ] || : > "$since"
  [ "$kind" = edit ] || : > "$milestone"
}

# Human-readable summary of the ledger, one line per repo/branch.
vault_ledger_summary() {
  [ -s "$ledger" ] || return 0
  awk -F'\t' '
    { key=$3 "@" $4; if (!(key in seen)) { seen[key]=1; order[++n]=key; first[key]=$1 } last[key]=$1
      if ($2=="edit") { ne[key]++; if (ne[key]<=12) files[key]=files[key] (ne[key]>1?", ":"") $5 }
      else if ($2=="commit") commits[key]=commits[key] (commits[key]?"; ":"") $1 " \"" $5 "\""
      else if ($2=="push") pushes[key]=pushes[key] (pushes[key]?"; ":"") $1 " " $5
      else if ($2=="pr") prs[key]=prs[key] (prs[key]?"; ":"") $1 " " $5 }
    END { for (i=1;i<=n;i++) { k=order[i]; line=k " (" first[k] "-" last[k] ")"
      if (ne[k]) line=line " edited " ne[k] " file" (ne[k]>1?"s":"") ": " files[k] (ne[k]>12?", +" ne[k]-12 " more":"")
      if (commits[k]) line=line " | commits: " commits[k]
      if (pushes[k]) line=line " | pushed: " pushes[k]
      if (prs[k]) line=line " | PRs: " prs[k]
      print line } }' "$ledger"
}
