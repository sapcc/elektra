#!/bin/bash

ELEKTRA_PORT=$(wb elektra 'echo $APP_PORT' | tail -1 | tr -d '\r')

if [[ -n "$ELEKTRA_PORT" ]]; then
  echo "Workspaces and Elektra found :-)"
  wb elektra "bundle exec rspec"
  wb elektra "yarn test"
  exit
else
  echo "Try to run local mode..."
  bundle exec rspec
  yarn test
  exit
fi

