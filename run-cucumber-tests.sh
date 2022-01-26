#!/bin/bash

if [[ -n "${CUCUMBER_PROFILE}" ]]; then
  ln -s /app/bundle/ ./bundle && \
  # show all hidden chars for debugging
  # echo $CAPYBARA_APP_HOST | cat -A
  bundle exec cucumber -p $CUCUMBER_PROFILE

  # delete symlink in any case!
  echo "Cleanup..."
  rm ./bundle > /dev/null 2>&1
else
  echo 'No $CUCUMBER_PROFILE found!'
  echo ""
  echo "Wrong context? This script is for development and runs only inside the"
  echo "testing container. To run elektra cucumber tests check features/run.sh"
fi
