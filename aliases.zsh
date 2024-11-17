
alias c="clear"
# yarn aliases
alias y="yarn"
alias yi="yarn install"
alias yt="yarn test"
alias yte="yarn test:e2e"
alias yti="yarn test:inte"
alias ys="yarn start"

alias sano="cd ~/Development/CorpoSano/"
alias tied="cd ~/Development/TiedSiren/"
alias giveAccentsBack="defaults write -g ApplePressAndHoldEnabled -bool true"
alias nrt="npm run test"

#Yann magic aliases
alias gupm="gup origin master"
alias gupd="gup origin develop"
alias gcountm="git rev-list --count HEAD ^origin/master"
alias gcountd="git rev-list --count HEAD ^origin/develop"
alias grbim="git rebase -i HEAD~\$(gcountm)"
alias grbid="git rebase -i HEAD~\$(gcountd)"
alias vmajor="gco master && gup && npm version major --git-tag-version && ggpush && ggpush --tags"
alias vminor="gco master && gup && npm version minor --git-tag-version && ggpush && ggpush --tags"
alias vpatch="gco master && gup && npm version patch --git-tag-version && ggpush && ggpush --tags"

#adb shortcuts
alias adb-menu="adb shell input keyevent 82"
alias adb-unlock="adb shell input keyevent KEYCODE_WAKEUP && adb shell input swipe 500 1500 500 500 && sleep 1 && adb shell input text 5068 && adb shell input keyevent KEYCODE_ENTER"
alias adb-open-notif= "adb shell input swipe 0 0 0 1000"
alias adb-close-notif="adb shell am broadcast -a android.intent.action.CLOSE_SYSTEM_DIALOGS"
alias adb-back="adb shell input keyevent KEYCODE_BACK"

alias s="speedtest"

alias np="npm i --save-dev --save-exact prettier && npx prettier . --write"
alias yp="yarn add --dev --exact prettier && cp ~/Development/zsh-aliases/prettierrc.json && yarn prettier . --write"

alias jqscripts="jq '.scripts' package.json"
