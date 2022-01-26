#!/bin/bash

CUCUMBER_PROFILE=$1
CCTEST_USER=$2
CCTEST_PASSWORD=$3
CCTEST_PROJECT=$4
CAPYBARA_APP_HOST=$5
ELEKTA_PATH=${6-"/workspace/elektra"}

function help_me () {
  echo "Usage: run.sh CUCUMBER_PROFILE CCTEST_USER CCTEST_PASSWORD CCTEST_PROJECT CAPYBARA_APP_HOST ELEKTA_PATH*"
  exit 1
}

if [[ "$1" == "--help" ]]; then
  help_me
fi

# find the host if nothing was given
if [[ -z "${CAPYBARA_APP_HOST}" ]]; then
  if [ -f "/usr/local/bin/wb" ]; then
    # this runs only in workspaces!!!
    # sed 's/\x1b//g' remove ^[ ctrl-key
    # sed 's/\[0m//g') remove ESC key
    # https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
    ELEKTRA_PORT=$(wb elektra 'echo $APP_PORT' | tail -1 | tr -d '\r' | sed 's/\x1b//g' | sed 's/\[0m//g')
    echo "ELEKTRA_PORT      => $ELEKTRA_PORT"
    CAPYBARA_APP_HOST="http://localhost:$ELEKTRA_PORT"
  fi

  if [[ -z "${ELEKTRA_PORT}" ]]; then
    echo "Error: no ELEKTRA_PORT found"
    help_me
  fi
fi

if [[ -z "${CCTEST_USER}" ]]; then
  echo "Error: no CCTEST_USER found"
  help_me
fi

if [[ -z "${CCTEST_PASSWORD}" ]]; then
  echo "Error: no CCTEST_PASSWORD found"
  help_me
fi

if [[ -z "${CCTEST_PROJECT}" ]]; then
  echo "Error: no CCTEST_PROJECT found"
  help_me
fi

if [[ -z "${CAPYBARA_APP_HOST}" ]]; then
  echo "Error: no CAPYBARA_APP_HOST found"
  help_me
fi

echo "CAPYBARA_APP_HOST => $CAPYBARA_APP_HOST"
echo "CUCUMBER_PROFILE  => $CUCUMBER_PROFILE"
echo "CCTEST_USER       => $CCTEST_USER"
echo "CCTEST_DOMAIN     => cc3test"
echo "CCTEST_PROJECT    => $CCTEST_PROJECT"
echo "ELEKTRA_PATH      => $ELEKTA_PATH"
echo ""

docker run --rm -it \
  --volume $ELEKTA_PATH:/elektra \
  --env CAPYBARA_APP_HOST=$CAPYBARA_APP_HOST \
  --env CCTEST_DOMAIN=cc3test \
  --env CCTEST_PROJECT=$CCTEST_PROJECT \
  --env CCTEST_USER=$CCTEST_USER \
  --env CCTEST_PASSWORD=$CCTEST_PASSWORD \
  --env CUCUMBER_PROFILE=$CUCUMBER_PROFILE \
  --workdir /elektra \
  --network=host \
  keppel.eu-de-1.cloud.sap/ccloud/elektra-integration-tests \
  /bin/bash -c "./run-cucumber-tests.sh"
  
  #cd /elektra/ && ln -s /app/bundle/ ./bundle && echo $CUCUMBER_PROFILE && env | grep CUCU && rm ./bundle"