#!/bin/bash

# this script for development, runs inside the testing container 
# to run tests check features/run.sh

ln -s /app/bundle/ ./bundle && \
# show all hidden chars for debugging
# echo $CAPYBARA_APP_HOST | cat -A
bundle exec cucumber -p $CUCUMBER_PROFILE

# delete symlink in any case!
rm ./bundle > /dev/null 2>&1
