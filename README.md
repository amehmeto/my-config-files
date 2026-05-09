# my-config-files

One-command setup for a fresh Mac.

## Quick start

```bash
# HTTPS clone — works on a fresh Mac without an SSH key.
# Switch the remote to SSH later: git remote set-url origin git@github.com:amehmeto/my-config-files.git
git clone https://github.com/amehmeto/my-config-files.git ~/Development/my-config-files
cd ~/Development/my-config-files
bash install.sh
```

`install.sh` will:
1. Install **Homebrew** (if missing)
2. Run `brew bundle` with the Brewfile (CLI tools, casks, taps)
3. Install **Oh My Zsh** (if missing)
4. Symlink dotfiles to `~`
5. Optionally apply macOS preferences (`macos/defaults.sh`)

## What gets symlinked

| Source | Target |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `git/.gitconfig` | `~/.gitconfig` |
| `git/.gitignore_global` | `~/.gitignore_global` |
| `vim/.vimrc` | `~/.vimrc` |
| `vim/.ideavimrc` | `~/.ideavimrc` |
| `prettier/.prettierrc` | `~/.prettierrc` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/commands/` | `~/.claude/commands/` |
| `claude/hooks/` | `~/.claude/hooks/` |

## Repo structure

```
zsh/            Shell config — .zshrc, aliases, iTerm colors
git/            Git config and global gitignore
vim/            Vim and IdeaVim config
prettier/       Prettier config
macos/          macOS system preferences script
Brewfile        Homebrew packages and casks
install.sh      Bootstrap script
```

## Manual steps after install

### iTerm2
- **Disable inactive pane dimming:** Settings > Appearance > Dim
- **Reuse directory for new tabs:** Preferences > Profiles > Working Directory > "Reuse previous session's directory"
- **Silent bell:** Preferences > Profiles > Terminal > Silence bell
- **Disable dimming on command selection:** Preferences > General > Selection > uncheck "Clicking on a command selects it"
- **Unlimited scrollback:** Preferences > Profiles > Terminal > check "Unlimited scrollback"
- **Open files in WebStorm:** Preferences > Profiles > Advanced > Semantic History > WebStorm
- **Window size:** Preferences > Profiles > Window > Columns: 80, Rows: 80

### Git credentials
```bash
gh auth login
```

### Local secrets (`~/.zshrc.local`)
The repo's `.zshrc` sources `~/.zshrc.local` if it exists. Put machine-specific
secrets there (NPM_TOKEN, API keys, work env vars). Copy this file manually
from the old machine — it is **not** versioned.

### Mac App Store apps
The Brewfile uses `mas` for App Store apps. You must sign in to the App Store
**before** running `brew bundle`, otherwise mas entries will fail. After signing
in, re-run:
```bash
brew bundle --file=~/Development/my-config-files/Brewfile
```

### Apps not in Homebrew or App Store
- [Pop](https://pop.com/)
- IceBar (menu bar utility)

### What to migrate manually (NOT in repo)
- `~/.ssh/` — SSH keys (transfer via AirDrop or USB, never git)
- `~/.aws/` — AWS credentials and SSO config
- `~/Documents/Obsidian Vault/` — coaching vault
- `~/Library/LaunchAgents/com.arthurmehmetoglu.daily-coach.plist` — daily coach launchd job
- `~/bin/` — personal scripts
- `/etc/hosts` custom entries (kubernetes.docker.internal, etc.)
- fnm node versions: `fnm install 22 && fnm install 20 && fnm default 22`
- npm globals: `npm i -g eas-cli firebase-tools vercel happy-coder`
