#!/usr/bin/env bash
# Bootstrap a fresh Mac from this repo.
# Usage:
#   git clone https://github.com/amehmeto/my-config-files.git ~/Development/my-config-files
#   cd ~/Development/my-config-files && bash install.sh
#
# No flags. Runs the whole setup. Prompts (via macOS dialogs) when it
# needs you — sudo password, App Store sign-in.

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
# 2. Brew Bundle (with sudo + App Store intervention prompts)
# ---------------------------------------------------------------------------
if [[ ! -f "$DOTFILES/Brewfile" ]]; then
  warn "No Brewfile found at $DOTFILES/Brewfile — skipping bundle"
else
  # ---- 2a. Sudo: cache credentials via a GUI askpass helper ----------------
  # Many casks (docker, opera-gx, .pkg installers) call `sudo` mid-install,
  # often as `sudo -A` from a subshell where sudo's normal credential cache
  # doesn't apply (timestamp_type=tty). To prompt the user only ONCE, the
  # askpass helper itself caches the password in a 0600 tmp file after the
  # first call and reuses it for every subsequent invocation.
  #
  # SECURITY NOTE: the cached password sits on disk (mode 0600 in $TMPDIR,
  # typically /var/folders/...) for the duration of brew bundle. The EXIT
  # trap below wipes and unlinks it. SIGKILL bypasses the trap, so an `kill
  # -9` of install.sh would leave the file behind until /tmp is reaped.
  PW_FILE="$(mktemp -t install-sh-pw.XXXXXX)"
  chmod 600 "$PW_FILE"
  ASKPASS="$(mktemp -t install-sh-askpass.XXXXXX)"
  cat > "$ASKPASS" <<ASKPASS_EOF
#!/usr/bin/env bash
# First call: prompt user via osascript, cache password to PW_FILE.
# Subsequent calls: just echo the cached password.
PW_FILE='$PW_FILE'
if [[ -s "\$PW_FILE" ]]; then
  cat "\$PW_FILE"
  exit 0
fi
pw=\$(/usr/bin/osascript <<'APPLESCRIPT'
tell application "System Events"
  activate
  display dialog "install.sh needs your Mac password to install casks (Docker, Opera GX, Microsoft Teams/Word, .pkg installers).

You'll only be asked once — the password is cached in memory for the duration of install.sh and wiped when it exits." ¬
    default answer "" with title "install.sh — Mac password" ¬
    with icon caution with hidden answer
  return text returned of result
end tell
APPLESCRIPT
)
[[ -z "\$pw" ]] && exit 1
# sudo's askpass protocol expects a newline-terminated password.
printf '%s\n' "\$pw" > "\$PW_FILE"
printf '%s\n' "\$pw"
ASKPASS_EOF
  chmod +x "$ASKPASS"
  export SUDO_ASKPASS="$ASKPASS"
  cleanup_sudo() {
    [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    # Best-effort wipe before unlink (the kernel zeros tmpfs anyway, but be explicit).
    [[ -f "$PW_FILE" ]] && : > "$PW_FILE"
    rm -f "$PW_FILE" "$ASKPASS"
  }
  trap cleanup_sudo EXIT

  info "Caching sudo credentials (a password dialog will appear)..."
  if sudo -A -v 2>/dev/null; then
    ok "Sudo cached — install.sh won't ask again"
    # Keep sudo alive in the background until install.sh exits.
    ( while true; do sudo -n true 2>/dev/null || break; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
    SUDO_KEEPALIVE_PID=$!
  else
    warn "Sudo not cached (cancelled or osascript unavailable). Casks needing sudo will fail."
  fi

  # ---- 2b. App Store sign-in for `mas` entries -----------------------------
  if grep -qE '^[[:space:]]*mas ' "$DOTFILES/Brewfile" && command -v mas &>/dev/null; then
    if ! mas account &>/dev/null; then
      info "App Store not signed in — opening App Store and waiting for sign-in..."
      open -a "App Store" || true
      osascript >/dev/null 2>&1 <<'APPLESCRIPT' || true
tell application "System Events"
  activate
  display dialog "install.sh needs you to sign in to the App Store so it can install Xcode and other Mac App Store apps.

The App Store has been opened. Sign in there, then click OK to continue.

(Click Skip to skip Mac App Store apps for now.)" ¬
    with title "install.sh — App Store sign-in" ¬
    with icon caution ¬
    buttons {"Skip", "OK"} default button "OK"
  if button returned of result is "Skip" then
    error number -128
  end if
end tell
APPLESCRIPT
      if mas account &>/dev/null; then
        ok "App Store signed in as $(mas account)"
      else
        warn "Still not signed in — mas entries will be skipped/fail."
      fi
    else
      ok "App Store signed in as $(mas account)"
    fi
  fi

  # ---- 2c. Run brew bundle -------------------------------------------------
  info "Installing Homebrew packages (this may take a while)..."
  if ! brew bundle --file="$DOTFILES/Brewfile"; then
    warn "Some Brewfile entries failed — check output above"
  fi
  ok "Brew bundle complete"
fi

# ---------------------------------------------------------------------------
# 3. Oh My Zsh
# ---------------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
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
# 5. macOS defaults
# ---------------------------------------------------------------------------
if [[ -f "$DOTFILES/macos/defaults.sh" ]]; then
  info "Applying macOS preferences..."
  bash "$DOTFILES/macos/defaults.sh"
  ok "macOS preferences applied"
else
  warn "No macos/defaults.sh found — skipping"
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
echo "  4. Copy ~/.zshrc.local from old machine (NPM_TOKEN, secrets)"
echo "  5. Install fnm node versions:  fnm install 22 && fnm install 20 && fnm default 22"
echo ""
