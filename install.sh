#!/usr/bin/env bash
# Bootstrap a fresh Mac from this repo.
# Usage: git clone <repo> ~/Development/my-config-files && cd ~/Development/my-config-files && bash install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m→ %s\033[0m\n' "$1"; }
ok()    { printf '\033[1;32m✓ %s\033[0m\n' "$1"; }
warn()  { printf '\033[1;33m! %s\033[0m\n' "$1"; }

# ---------------------------------------------------------------------------
# 1. Homebrew
# ---------------------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon Macs
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  ok "Homebrew already installed"
fi

# ---------------------------------------------------------------------------
# 2. Brew Bundle
# ---------------------------------------------------------------------------
info "Installing Homebrew packages (this may take a while)..."
brew bundle --file="$DOTFILES/Brewfile" || warn "Some Brewfile entries failed — check output above"
ok "Brew bundle complete"

# ---------------------------------------------------------------------------
# 3. Oh My Zsh
# ---------------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

# ---------------------------------------------------------------------------
# 4. Symlinks
# ---------------------------------------------------------------------------
info "Creating symlinks..."

symlink() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    rm "$dst"
  elif [[ -f "$dst" ]]; then
    mv "$dst" "${dst}.backup"
    warn "Backed up existing $dst → ${dst}.backup"
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

# ---------------------------------------------------------------------------
# 5. macOS defaults (optional)
# ---------------------------------------------------------------------------
echo ""
read -rp "Apply macOS preferences (Dock, Finder, keyboard)? [y/N] " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  bash "$DOTFILES/macos/defaults.sh"
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
echo ""
