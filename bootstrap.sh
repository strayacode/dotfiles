#!/bin/sh

BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

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

info "Some info text"
warn "Some user text"
success "Some success text"
print "Print some text"
fail "Some fail text"
