# dotfiles

macOS setup managed with [chezmoi](https://chezmoi.io). Secrets come from 1Password (personal account, `op://Private/dotfiles/<FIELD>`), never the repo.

## Install on a new Mac

### Before you start

- An Apple Silicon Mac (Homebrew lives in `/opt/homebrew`).
- Your Mac login password (Homebrew asks for it).
- A GitHub account and your personal 1Password account (`my.1password.com`, item `dotfiles` in vault `Private`). No access? Answer "no" to the secrets question and fill them in later.
- Power plugged in: the full run takes a while, mostly `brew bundle`.

### 1. Run one command

Open Terminal and paste:

```sh
curl -fsSL https://raw.githubusercontent.com/luciengeorge/dotfiles/main/bootstrap.sh | bash
```

Each step prints a blue `==>` header, and installs show their own output, so you can follow along.

### 2. Answer the prompts

They come in this order. Everything else runs on its own.

| Step | What you do |
| --- | --- |
| Xcode Command Line Tools | Click Install in the popup, wait, press enter in Terminal |
| Homebrew | Type your Mac password, press enter to confirm |
| GitHub login | Copy the code shown, press enter, approve in the browser |
| 1Password | Open the app, sign in, turn on Settings > Developer > Integrate with 1Password CLI, press enter |
| "Pull secrets from 1Password" | `y` (or `n` to leave secrets as `REPLACE_ME`) |
| Touch ID / 1Password approval | Approve when `op` asks to read the secrets |

### 3. Wait for the install

The Obsidian vault (private repo) is cloned to `~/obsidian` with a hook that pushes each commit. The repo is cloned to `~/src/luciengeorge/dotfiles`, the config files are linked into `~`, then these run in order:

1. Vite+ (node, npm, pnpm)
2. `brew bundle` from `Brewfile` (apps and CLIs). A failed entry prints a warning and the rest carries on.
3. Non-Homebrew macOS apps (`GotEmail`, `Wonder`) and Sublime Package Control
4. Global npm / pnpm / bun / uv packages from `packages/*.txt`
5. Ruby from `~/.rbenv/version` (compiles, a few minutes)
6. Agent skills from `skills/skill-lock.json`
7. Claude plugins and marketplaces
8. gh extensions

It ends with `==> Done. Open a new terminal.`

### 4. After install

- Open a new terminal so the shell config loads.
- Sign in to the apps you use (1Password, Slack, Chrome, Claude, etc.).
- Obsidian: open `~/obsidian` as a vault, then log in again to the Garmin and Strava plugins (their tokens aren't in git).
- SSH: create a key (or use 1Password's SSH agent), add it to GitHub as an auth and a signing key, then add it to `home/dot_config/git/allowed_signers`.

### If something fails

| Problem | Fix |
| --- | --- |
| Script stopped part way | Fix the cause, then run the one-liner again, or `chezmoi apply` if the repo is already cloned |
| Some Brewfile apps missing | `brew bundle --file=~/src/luciengeorge/dotfiles/Brewfile` |
| Said no to secrets, want them now | `chezmoi init --prompt`, answer `y`, then `chezmoi apply` |
| A secret is `REPLACE_ME` | Check the field exists in the 1Password `dotfiles` item, then `chezmoi apply` |

### Keep it up to date

- Pull and apply changes from the repo: `chezmoi update`
- Install scripts re-run only when their lists change (`Brewfile`, `packages/*.txt`, `~/.rbenv/version`, etc.).

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
| `grok-bot/` | Grok Bot fleet templates and setup prompt (not applied by chezmoi) |

## Day to day

- Plain files are symlinked to this repo, so edits land here directly.
- `private_` and template files are copies. After an app rewrites one (Claude `settings.json`, Warp `settings.toml`, T3 Code `~/.t3/userdata/*.json`), run `chezmoi re-add`.
- New secret: add a field to the `dotfiles` 1Password item, reference it with `{{ includeTemplate "op" (dict "ctx" . "field" "NAME") }}`.
- Machine-only shell config: `~/.config/zsh/local.zsh` (not tracked).
- Refresh lists: `brew bundle dump --describe --force`, `npm ls -g`, `cp ~/.agents/.skill-lock.json skills/` (trim to `source*`/`skillPath`).
