# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------------------
# Config repo location
# ---------------------------------------------------------------------------
DOTFILES="$HOME/Development/my-config-files"

# ---------------------------------------------------------------------------
# PATH exports
# ---------------------------------------------------------------------------
export PATH="/usr/local/share/npm/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/usr/local/opt/openjdk@17/bin:$PATH"
export PATH="/usr/local/opt/php@8.2/bin:$PATH"
export PATH="/usr/local/opt/php@8.2/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------------------------------------------------------
# fnm (Fast Node Manager)
# ---------------------------------------------------------------------------
export PATH="$HOME/.fnm:$PATH"
eval "$(fnm env --use-on-cd)"

# ---------------------------------------------------------------------------
# bun
# ---------------------------------------------------------------------------
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ---------------------------------------------------------------------------
# aitdd
# ---------------------------------------------------------------------------
export AITDD_INSTALL="$HOME/.aitdd"
export PATH="$AITDD_INSTALL/bin:$PATH"

# ---------------------------------------------------------------------------
# Android SDK
# ---------------------------------------------------------------------------
export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_NDK_HOME="$HOME/Development/Android/AndroidNDK11579264.app"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"

# ---------------------------------------------------------------------------
# Source config files
# ---------------------------------------------------------------------------
source "$DOTFILES/zsh/aliases.zsh"
source "$DOTFILES/zsh/iterm-colors.zsh"
