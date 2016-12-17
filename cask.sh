#
# Application installer (via brew-cask)
#

set -e

# Apps
apps=(
  1password
  atom
  boxer
  caffeine
  charles
  colloquy
  dropbox
  filezilla
  firefox
  firefoxdeveloperedition
  flux
  google-chrome
  google-chrome-canary
  hex-fiend
  hyper
  imagealpha
  imageoptim
  kaleidoscope
  ksdiff
  laullon-gitx
  mamp
  ngrok
  ntfsmounter
  openemu
  opera
  opera-beta
  qlcolorcode
  qlmarkdown
  qlprettypatch
  qlstephen
  quicklook-json
  recordit
  skype
  slowy
  spectacle
  steam
  sublime-text2
  the-unarchiver
  torbrowser
  transmission
  virtualbox
  visual-studio-code
  vlc
)

# Fonts
fonts=(
  font-clear-sans
  font-hack
  font-roboto
)

# Specify the location of the apps
appdir="/Applications"

# Check for Homebrew
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

main() {

  # Ensure homebrew is installed
  homebrew

  # Install homebrew-cask
  echo "installing cask..."
  brew install caskroom/cask/brew-cask

  # Cask tab completion
  brew install homebrew/completions/brew-cask-completion

  # Tap alternative versions
  brew tap caskroom/versions

  # Tap the fonts
  brew tap caskroom/fonts

  # install apps
  echo "installing apps..."
  brew cask install --appdir=$appdir ${apps[@]}

  # install fonts
  echo "installing fonts..."
  brew cask install ${fonts[@]}

  cleanup
}

homebrew() {
  if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

cleanup() {
  brew cleanup
}

main "$@"
exit 0
