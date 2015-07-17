#!/usr/bin/env bash

configure-keyboard-remaps(){

  log "Configuring keyboard remaps"

  # TODO: log --debug to just echo without coloring

  # need to open them to be able to configure
  open "/Applications/Karabiner.app" "/Applications/Seil.app"

  # let them open up
  sleep 5

  # TODO: echo this info as well
  # NOTE: make sure to change following key mappings in System Preferences -> Keyboard
  # Mission Control, Move left a space, Move right a space, Mission Control, Aplication Windows
  # Launchpad & Dock, Turn dock hiding On/Off
  # Modifier Keys, Switch off Caps Lock default behavior
  # Input Sources, disable "Select the previous input source",
  # Input Sources, map "Select next source in Input menu" to "F13" (mapped to CapsLock)
  # All Applications, disable "Show help menu"
  export karabiner_cli="/Applications/Karabiner.app/Contents/Library/bin/karabiner"
  export seil_cli="/Applications/Seil.app/Contents/Library/bin/seil"

  if [ "$($karabiner_cli list | wc -l)" -lt 2 ]; then
    $karabiner_cli append "PC Keyboard"
    $karabiner_cli select_by_name "PC Keyboard"
    sh "$DOTFILES/system/karabiner-profile-pc.sh"

    $karabiner_cli append "Mac Keyboard"
    $karabiner_cli select_by_name "Mac Keyboard"
    sh "$DOTFILES/system/karabiner-profile-mac.sh"

    # select first profile
    $karabiner_cli select 0

    sh "$DOTFILES/system/seil-profile.sh"

    # TODO: show menu which profile to choose
    log "\nMake sure to select profile in Karabiner preferences"
  else
    echo "You already have Karabiner profiles installed. Skip configuring profiles"
  fi
}

configure-slate(){

  # TODO: need to enable Slate in "System Preferences" -> "Security & Privacy" -> "Accessibility"
  log "Configuring slate"
  _ln -t ~ "${DOTFILES}/system/.slate.js"

  # let Slate automatically check for updates
  defaults write com.slate.Slate SUEnableAutomaticChecks -int 1

  # this is to make Slate happy w/o spaces in path
  ln -sf "/Applications/Google Chrome.app" "/Applications/Google_Chrome.app"
}

install-truecrypt(){
  # download dmg
  log "Installing truecrypt@7.1a"

  curl -o "$DOTFILES/tmp/truecrypt.dmg" "https://www.grc.com/misc/truecrypt/TrueCrypt%207.1a%20Mac%20OS%20X.dmg"

  # mount and automatically accept EULA
  yes | hdiutil attach "$DOTFILES/tmp/truecrypt.dmg" > /dev/null

  # TrueCrypt 7.1a incorrectly detect OSX verison, and thinks 10.10 < 10.4
  # see Install TrueCrypt On Mac OS X Yosemite 10.10 — Lazy Mind -  https://lazymind.me/2014/10/install-truecrypt-on-mac-osx-yosemite-10-10/

  # on Yosemite and upcoming versions: 10.11, 10.12
  # install inner packages in correct order: OSXFUSECore.pkg, OSXFUSEMacFUSE.pkg, MacFUSE.pkg, TrueCrypt.pkg
  if [[ "$(sw_vers -productVersion)" =~ "^10\.1" ]]; then
    sudo installer -pkg "/Volumes/TrueCrypt 7.1a/TrueCrypt 7.1a.mpkg/Contents/Packages/OSXFUSECore.pkg" -target /

    sudo installer -pkg "/Volumes/TrueCrypt 7.1a/TrueCrypt 7.1a.mpkg/Contents/Packages/OSXFUSEMacFUSE.pkg" -target /

    sudo installer -pkg "/Volumes/TrueCrypt 7.1a/TrueCrypt 7.1a.mpkg/Contents/Packages/MacFUSE.pkg" -target /

    sudo installer -pkg "/Volumes/TrueCrypt 7.1a/TrueCrypt 7.1a.mpkg/Contents/Packages/TrueCrypt.pkg" -target /

  # on Mavericks and below, just run the installer for main pgg
  else
    sudo installer -pkg "/Volumes/TrueCrypt 7.1a/TrueCrypt 7.1a.mpkg" -target /
  fi

  # unmount dmg
  hdiutil detach "/Volumes/TrueCrypt 7.1a"
}

configure-osx-defaults(){
  log "Changing OSX system defaults and behavior"
  source "${DOTFILES}/system/osx.sh"
}

configure-macpass(){
  defaults write com.hicknhacksoftware.MacPass ShowInspector -bool false
  defaults write com.hicknhacksoftware.MacPass EnableGlobalAutotype -bool true

  # see http://hints.macworld.com/article.php?story=20131123074223584
  # see http://osxnotes.net/keybindings.html for valid key chords
  defaults write com.hicknhacksoftware.MacPass NSUserKeyEquivalents '{
  "Copy Password"="@c";
  "\033File\033Lock"="@l";
}'
}

log "Installing fonts"
brew cask install \
  font-droid-sans-mono \
  font-dejavu-sans \
  font-inconsolata-dz \
  font-source-code-pro || true

log "Installing packages"
brew install \
  shellcheck \
  tree \
  todo-txt || true

log "Installing applications"
brew cask install \
  diffmerge \
  google-chrome \
  dropbox \
  karabiner \
  seil \
  key-codes \
  macpass \
  skype \
  slack \
  utorrent \
  mattr-slate \
  secrets \
  dash \
  fseventer \
  vlc || true

configure-osx-defaults
configure-slate
configure-keyboard-remaps
install-truecrypt

log "Done. Please logout/restart to have all changes applied for sure"
