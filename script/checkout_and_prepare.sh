#!/bin/bash

# exit when any command fails
set -e

if [ ! -f README.md ]; then
  echo "Execute this script from the toplevel directory."
  exit 1
fi

if [ "$1" == "--help" ]; then
  echo "this script is for debugging to checkout a specific version (default is HEAD) and prepare elektra to run"
  echo "Usage: checkout_and_prepare.sh COMMIT*"
  exit 0
fi

echo "INFO: please be aware that you should stop puma and webpacker first!"
read -p "INFO: setup elektra? (y/n)" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  COMMIT=${1-HEAD}

  if [ -n "$COMMIT" ]; then
    git checkout $COMMIT 
  fi

  rm -rf ./node_modules/ &&
  yarn &&
  bundle install &&
  echo "" &&
  echo "INFO: Checkout and preparations for release $COMMIT done" &&
  git show $COMMIT &&
  echo "" &&
  echo "INFO: You can now start puma and webpacker for testing."
else
  echo ""
  echo "INFO: canceled!"
fi

