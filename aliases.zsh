
alias c="clear"

# yarn aliases
alias y="yarn"
alias yi="yarn install"
alias yt="yarn test"
alias yte="yarn test:e2e"
alias yti="yarn test:inte"
alias ys="yarn start"

# npm aliases
alias n="npm"
alias nr="npm run"
alias nri="npm run install"
alias nrt="npm run test"
alias nrtu="npm run test:unit"
alias nrte="npm run test:e2e"
alias nrteu="npm run test:e2e:ui"
alias nrti="npm run test:inte"
alias nrtc="npm run test:contract"
alias nrs="npm run start"
alias nrsd="npm run start:dev"
alias nrd="npm run dev"
alias nrdm="npm run dev:mock"
alias nrba="npm run build:all"
alias nrbc="npm run build:common"
alias nrbr="npm run build:react"
alias nrta="npm run test:all"
alias nrtc="npm run test:common"
alias nrtr="npm run test:react"

# Development shortcuts
alias sano="cd ~/Development/CorpoSano/"
alias tied="cd ~/Development/TiedSiren/"
alias giveAccentsBack="defaults write -g ApplePressAndHoldEnabled -bool true"

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

#For Hermes Admin UI
alias syncui="(cd ~/Development/admin-ui-component && npm run build:all) && cp -rv ~/Development/admin-ui-component/packages/common/dist ~/Development/admin-ui-customer/node_modules/@hermes-digital/common-ui/ && cp -rv ~/Development/admin-ui-component/packages/ui/react/components-lib/dist ~/Development/admin-ui-customer/node_modules/@hermes-digital/design-system-react/ && rm -rfv ~/Development/admin-ui-customer/node_modules/.vite && touch src/main.tsx"
alias syncui-common="(cd ~/Development/admin-ui-component && npm run build:all) && cp -rv ~/Development/admin-ui-component/packages/common/dist ~/Development/admin-ui-customer/node_modules/@hermes-digital/common-ui/ && rm -rfv ~/Development/admin-ui-customer/node_modules/.vite && touch ~/Development/admin-ui-customer/src/env.d.ts"
alias syncui-react="(cd ~/Development/admin-ui-component && npm run build:all) && cp -rv ~/Development/admin-ui-component/packages/ui/react/components-lib/dist ~/Development/admin-ui-customer/node_modules/@hermes-digital/design-system-react/ && rm -rfv ~/Development/admin-ui-customer/node_modules/.vite && touch src/main.tsx"
alias revertsync="rm -rf ~/Development/admin-ui-customer/node_modules/@hermes-digital/common-ui ~/Development/admin-ui-customer/node_modules/@hermes-digital/design-system-react node_modules/.vite && npm install"

# Gitlab aliases
alias gpcv="glab pipeline ci view"
alias gpcvw="glab pipeline ci view --web"

#adb shortcuts
alias adb-menu="adb shell input keyevent 82"
alias adb-unlock="adb shell input keyevent KEYCODE_WAKEUP && adb shell input swipe 500 1500 500 500 && sleep 1 && adb shell input text 5068 && adb shell input keyevent KEYCODE_ENTER"
alias adb-open-notif= "adb shell input swipe 0 0 0 1000"
alias adb-close-notif="adb shell am broadcast -a android.intent.action.CLOSE_SYSTEM_DIALOGS"
alias adb-back="adb shell input keyevent KEYCODE_BACK"

alias s="speedtest"
alias pcat="pygmentize -g -O style=lightbulb"

alias np="npm i --save-dev --save-exact prettier && npx prettier . --write"
alias yp="yarn add --dev --exact prettier && cp ~/Development/zsh-aliases/prettierrc.json && yarn prettier . --write"

# Prettier
alias np="npm i --save-dev --save-exact prettier"
alias yp="yarn add --dev --exact prettier"

alias jqs="jq '.scripts' package.json"
alias jqd="jq '.dependencies' package.json"
alias jqdd="jq '.devDependencies' package.json"

# source
alias srcz="source ~/.zshrc"
alias srcb="source ~/.bashrc"

# Function to git add all, commit with a message, and push
gacp() {
  gaa && gcmsg "$1" && gp
}
