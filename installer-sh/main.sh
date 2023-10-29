#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

CWD=$(cd "$(dirname "$0")" && pwd -P)

main() {
  if (( "$#" < 1 )); then
    install-packages
    exit 0
  fi

  case "${1}" in
    install-package)
      shift
      install-package "$@"
      ;;
  esac
}

install-packages() {
  for pkg in "$CWD"/packages/*; do
    bash "$pkg"
  done
}

install-package() {
  if (( "$#" < 1 )); then
    >&2 echo 'A package name is required'
    return 255
  fi

  NAME=$1
  if [ -e "$CWD"/packages/"$NAME" ]; then
    bash "$CWD"/packages/"$NAME"
  else
    >&2 echo "$NAME is not found"
    return 255
  fi
}

main "$@"
