#!/usr/bin/env bash
# Bootstrap a fresh Mac from this repo.
# Usage (fresh machine — no SSH key yet, use HTTPS):
#   git clone https://github.com/amehmeto/my-config-files.git ~/Development/my-config-files
#   cd ~/Development/my-config-files && bash install.sh
#
# Flags:
#   --skip-brew      skip Homebrew install + brew bundle (useful for re-runs)
#   --skip-omz       skip Oh My Zsh install
#   --skip-macos     skip the macOS defaults prompt
#   --yes            assume "yes" to interactive prompts (apply macOS defaults)

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

SKIP_BREW=0
SKIP_OMZ=0
SKIP_MACOS=0
ASSUME_YES=0
for arg in "$@"; do
  case "$arg" in
    --skip-brew)  SKIP_BREW=1 ;;
    --skip-omz)   SKIP_OMZ=1 ;;
    --skip-macos) SKIP_MACOS=1 ;;
    --yes|-y)     ASSUME_YES=1 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

info()  { printf '\033[1;34m→ %s\033[0m\n' "$1"; }
ok()    { printf '\033[1;32m✓ %s\033[0m\n' "$1"; }
warn()  { printf '\033[1;33m! %s\033[0m\n' "$1"; }
skip()  { printf '\033[1;30m· %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. Homebrew
# ---------------------------------------------------------------------------
if (( SKIP_BREW )); then
  skip "Skipping Homebrew install (--skip-brew)"
elif ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# ---------------------------------------------------------------------------
# 2. Brew Bundle
# ---------------------------------------------------------------------------
if (( SKIP_BREW )); then
  skip "Skipping brew bundle (--skip-brew)"
elif [[ ! -f "$DOTFILES/Brewfile" ]]; then
  warn "No Brewfile found at $DOTFILES/Brewfile — skipping bundle"
else
  info "Installing Homebrew packages (this may take a while)..."
  if ! brew bundle --file="$DOTFILES/Brewfile"; then
    warn "Some Brewfile entries failed — check output above (App Store apps need 'mas' sign-in)"
  fi
  ok "Brew bundle complete"
fi

# ---------------------------------------------------------------------------
# 3. Oh My Zsh
# ---------------------------------------------------------------------------
if (( SKIP_OMZ )); then
  skip "Skipping Oh My Zsh (--skip-omz)"
elif [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

# ---------------------------------------------------------------------------
# 4. Symlinks
# ---------------------------------------------------------------------------
info "Creating symlinks..."

# symlink <src> <dst>
#   - Skips with a warning if <src> doesn't exist (so we never create dangling links).
#   - If <dst> already points to <src>, no-op.
#   - If <dst> is a symlink (broken or to elsewhere), it's removed.
#   - If <dst> is a regular file or directory, it's backed up to <dst>.backup-<timestamp>.
symlink() {
  local src="$1" dst="$2"

  if [[ ! -e "$src" ]]; then
    warn "Skipped — source missing: $src"
    return 0
  fi

  if [[ -L "$dst" ]]; then
    if [[ "$(readlink "$dst")" == "$src" ]]; then
      ok "$dst → $src (already linked)"
      return 0
    fi
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    local backup="${dst}.backup-$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$backup"
    warn "Backed up existing $dst → $backup"
  fi

  ln -s "$src" "$dst"
  ok "$dst → $src"
}

symlink "$DOTFILES/zsh/.zshrc"            "$HOME/.zshrc"
symlink "$DOTFILES/git/.gitconfig"        "$HOME/.gitconfig"
symlink "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"
symlink "$DOTFILES/vim/.vimrc"            "$HOME/.vimrc"
symlink "$DOTFILES/vim/.ideavimrc"        "$HOME/.ideavimrc"
symlink "$DOTFILES/prettier/.prettierrc"  "$HOME/.prettierrc"

# Claude Code
mkdir -p "$HOME/.claude"
symlink "$DOTFILES/claude/settings.json"  "$HOME/.claude/settings.json"
symlink "$DOTFILES/claude/commands"       "$HOME/.claude/commands"
symlink "$DOTFILES/claude/hooks"          "$HOME/.claude/hooks"

# ---------------------------------------------------------------------------
# 5. macOS defaults (optional)
# ---------------------------------------------------------------------------
if (( SKIP_MACOS )); then
  skip "Skipping macOS defaults (--skip-macos)"
elif [[ ! -f "$DOTFILES/macos/defaults.sh" ]]; then
  warn "No macos/defaults.sh found — skipping"
else
  echo ""
  if (( ASSUME_YES )); then
    answer="y"
  elif [[ ! -t 0 ]]; then
    skip "Non-interactive shell — skipping macOS defaults (use --yes to apply)"
    answer="n"
  else
    read -rp "Apply macOS preferences (Dock, Finder, keyboard)? [y/N] " answer || answer="n"
  fi
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    bash "$DOTFILES/macos/defaults.sh"
  fi
fi

# ---------------------------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------------------------
echo ""
echo "============================================"
ok "Setup complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Open a new terminal tab to load the new .zshrc"
echo "  2. Configure iTerm2 manually (see README.md)"
echo "  3. Set up Git credential helper:  gh auth login"
echo "  4. Sign in to App Store, then re-run:  brew bundle --file=$DOTFILES/Brewfile"
echo "  5. Copy ~/.zshrc.local from old machine (NPM_TOKEN, secrets)"
echo "  6. Install fnm node versions:  fnm install 22 && fnm install 20 && fnm default 22"
echo ""
