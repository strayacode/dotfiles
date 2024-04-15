#!/bin/sh

BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
DOTFILES=$(pwd -P)

info() {
  printf "${BLUE}$1${RESET}\n"
}

warn() {
  printf "${YELLOW}$1${RESET}\n"
}

success() {
  printf "${GREEN}$1${RESET}\n"
}

fail() {
  printf "${RED}$1${RESET}\n"
  exit
}

print() {
  printf "$1\n"
}

link() {
  src=$1
  dst=$2
  skip=
  overwrite=

  print "Attempting to link: $src -> $dst"

  # check if destination already exists in some form
  if [[ -e "$dst" ]]
  then
    warn "Destination already exists: $dst"
    warn "What would you like to do? [s]kip, [o]verwrite"
    read -r choice < /dev/tty

    case "$choice" in
      s )
        skip='true';; 
      o )
        overwrite='true';; 
      * )
        ;;
    esac

    if [[ "$overwrite" == "true" ]]
    then
      rm -rf "$dst"
      success "Overwrote: $dst"
    fi

    if [[ "$skip" == "true" ]]
    then
      print "Skipping: $dst"
    fi
  fi

  if [[ "$skip" != "true" ]]
  then
    ln -s "$src" "$dst"
    success "Linked: $dst -> $src"
  fi
}

install_dotfiles() {
  find -H "$DOTFILES" -maxdepth 2 -name 'linker' -not -path '*.git*' | while read linkerfile
  do
    print "Found linker file: $linkerfile"

    cat "$linkerfile" | while read -r line
    do
      src=$(eval echo "$line" | cut -d '=' -f1)
      dst=$(eval echo "$line" | cut -d '=' -f2)

      dir=$(dirname "$dst")

      print "Attempting to create directory: $dir"
      if [ -d "$dir" ]
      then
        print "Directory already exists: $dir"
      else
        mkdir -p "$dir"
      fi

      link "$src" "$dst"

    done
  done
}

print "(1/5) Installing dependencies..."
sh dependencies.sh

print "(2/5) Installing dotfiles..."
install_dotfiles

print "(3/5) Starting yabai..."
yabai --start-service
yabai --restart-service

print "(4/5) Start skhd..."
skhd --start-service
skhd --restart-service

print "(5/5) Applying MacOS settings..."
sh macos-settings.sh

success "Bootstrapped successfully!"
success "Some changes may require a restart"
