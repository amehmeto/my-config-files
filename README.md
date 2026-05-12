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
   - Pops a single password dialog up front and caches it for casks that
     need `sudo` (Docker, Opera GX, `.pkg` installers).
   - If the Brewfile has `mas` entries and you're not signed into the App
     Store, opens the App Store and waits for you to sign in (or click Skip).
3. Install **Oh My Zsh** (if missing)
4. Symlink dotfiles to `~`
5. Apply macOS preferences (`macos/defaults.sh`)

No flags. Just `bash install.sh`.

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
| `tools/*` | `~/bin/*` |
| `iterm2/com.googlecode.iterm2.plist` | iTerm2 reads it via `LoadPrefsFromCustomFolder` |
| `raycast/raycast-config.rayconfig` | Auto-opened on M5 — click Import in Raycast dialog |

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
`gh` is installed by the Brewfile. Authenticate it once after the install:
```bash
gh auth login
```
Then add the credential helper to `~/.gitconfig.local` (NOT `~/.gitconfig` — that's
a symlink into the repo, so writing helpers there would version a machine-specific
homebrew path):
```bash
GH=$(command -v gh)
cat >> ~/.gitconfig.local <<EOF
[credential "https://github.com"]
	helper =
	helper = !$GH auth git-credential
[credential "https://gist.github.com"]
	helper =
	helper = !$GH auth git-credential
EOF
chmod 600 ~/.gitconfig.local
```
The repo's `.gitconfig` `[include]`s `~/.gitconfig.local` so these helpers
take effect automatically.

### Local secrets (`~/.zshrc.local`)
The repo's `.zshrc` sources `~/.zshrc.local` if it exists. Put machine-specific
secrets there (NPM_TOKEN, API keys, work env vars). Copy this file manually
from the old machine — it is **not** versioned.

### Mac App Store apps
`install.sh` now opens the App Store and prompts you to sign in before
`brew bundle` reaches the `mas` entries. If you click **Skip** in that dialog,
sign in later and re-run:
```bash
brew bundle --file=~/Development/my-config-files/Brewfile
```

### Apps not in Homebrew or App Store
- [Pop](https://pop.com/)
- IceBar (menu bar utility)

### What to migrate manually (NOT in repo)
- `~/.ssh/` — SSH keys (transfer via AirDrop or USB, never git)
- fnm node versions: `fnm install 22 && fnm install 20 && fnm default 22`
- npm globals: `npm i -g eas-cli firebase-tools vercel happy-coder`
