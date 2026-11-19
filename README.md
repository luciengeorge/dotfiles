# dotfiles

macOS setup managed with [chezmoi](https://chezmoi.io). Secrets come from 1Password (`op://Employee/dotfiles/<FIELD>`), never the repo.

## New Mac

```sh
curl -fsSL https://gist.githubusercontent.com/luciengeorge/beeb959749187d49628832f71a02ac7f/raw/bootstrap.sh | bash
```

The gist mirrors `bootstrap.sh` (repo is private). After editing it: `gh gist edit beeb959749187d49628832f71a02ac7f -f bootstrap.sh bootstrap.sh`.

`bootstrap.sh` is self-contained: CLT, Homebrew, gh (+ login), chezmoi, 1Password (waits for the CLI integration), then clones this repo to `~/src/luciengeorge/dotfiles` and runs `chezmoi init --apply`. Each step prints a blue `==>` header; installs stream their own output. A failed Brewfile entry warns instead of stopping the apply.
Apply then runs, in order:

1. Vite+ (node, npm, pnpm)
2. `brew bundle` from `Brewfile` (re-runs when it changes; third-party taps trusted via `~/.homebrew/trust.json`)
3. global npm / pnpm / bun / uv packages from `packages/*.txt`
4. Ruby version from `~/.rbenv/version` (`rbenv install`)
5. skills from `skills/skill-lock.json` (`npx skills add`, linked into Claude)
6. Claude plugins and marketplaces from `~/.claude/settings.json`
7. gh extensions

After: create an SSH key (or use 1Password's agent), add it to GitHub as auth + signing key, update `home/dot_config/git/allowed_signers`.

## Layout

| Path | What |
| --- | --- |
| `home/` | chezmoi source (`.chezmoiroot`) |
| `home/dot_zshrc`, `home/dot_config/zsh/` | shell, aliases, secrets (template) |
| `home/dot_claude/`, `home/dot_codex/`, `home/dot_config/opencode/` | agent config, skills, hooks |
| `home/modify_dot_claude.json.tmpl`, `home/dot_codex/modify_private_config.toml` | merge managed MCP servers into app-owned files |
| `home/.chezmoitemplates/` | shared templates (`op` secret helper, Codex config) |
| `home/.chezmoiscripts/` | install scripts |
| `Brewfile`, `packages/`, `skills/` | what gets installed |

## Day to day

- Plain files are symlinked to this repo, so edits land here directly.
- `private_` and template files are copies. After an app rewrites one (Claude `settings.json`, Warp `settings.toml`), run `chezmoi re-add`.
- New secret: add a field to the `dotfiles` 1Password item, reference it with `{{ includeTemplate "op" (dict "ctx" . "field" "NAME") }}`.
- Machine-only shell config: `~/.config/zsh/local.zsh` (not tracked).
- Refresh lists: `brew bundle dump --describe --force`, `npm ls -g`, `cp ~/.agents/.skill-lock.json skills/` (trim to `source*`/`skillPath`).
