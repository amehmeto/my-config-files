# Execute the following to add aliases to .zshrc

echo "source $(pwd)/aliases.zsh" >> ~/.zshrc

# Install speedtest

brew tap teamookla/speedtest
brew update
# Example how to remove conflicting or old versions using brew
# brew uninstall speedtest --force
# brew uninstall speedtest-cli --force
brew install speedtest --force

# Iterm config

Disable inactive pane dimming
Settings -> Appearance -> Dim
