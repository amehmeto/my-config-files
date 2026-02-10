# my-config-files

One-command setup for a fresh Mac.

## Quick start

```bash
git clone git@github.com:amehmeto/my-config-files.git ~/Development/my-config-files
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

### Apps not in Homebrew
- [Hotspot Shield](https://www.hotspotshield.com/)
- [Joy](https://getjoy.app/)
- [Pop](https://pop.com/)
- [ScreenBrush](https://screenbrush.app/)
