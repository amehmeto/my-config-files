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

## Disable inactive pane dimming
Settings -> Appearance -> Dim

## New tab within current directory
Click iTerm2 → Preferences → Profiles
In “Working Directory” section select “Reuse previous session’s directory”

## Silent bell
Preferences -> Profiles
Under Terminal tab, you will see Notifications header. Toggle the Silence bell option.

## Disable dimming on command selection
Preferences > General > Selection
Uncheck "Clicking on a command selects it to restrict Find and Filter"

## Unlimited scrollback
Preferences > Profiles > Terminal > Scrollback Buffer
Check "Unlimited scrollback"

## Open file on WebStorm from iTerm
Preference > Profiles > Advanced
Semantic History > Open with editor... > WebStorm
