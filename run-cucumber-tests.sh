#!/bin/bash

echo "Info: this script is for development, and runs only inside the testing container"
echo "      to run cucumber tests check features/run.sh"
echo ""

ln -s /app/bundle/ ./bundle && \
# show all hidden chars for debugging
# echo $CAPYBARA_APP_HOST | cat -A
bundle exec cucumber -p $CUCUMBER_PROFILE

# delete symlink in any case!
echo "Cleanup..."
rm ./bundle > /dev/null 2>&1
