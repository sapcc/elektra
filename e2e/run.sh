#!/bin/bash

function help_me () {

  echo "Usage: run.sh --host HOST --profile member|admin --debug CYPRESS-DEBUG-FLAG PLUGIN-TEST "
  echo "       run.sh --help                                                   # will print out this message"
  echo "       run.sh --host http://localhost:3000 landingpage                 # will only run landingpage tests"
  echo "       run.sh --host http://localhost:3000 --debug 'cypress:network:*' # will show debug information about the networking"
  echo "MAC users: ./run.sh --host http://host.docker.internal:3000"
  echo ""
  echo "Debugging options: https://docs.cypress.io/guides/references/troubleshooting#Log-sources"
  echo "cypress:cli                 The top-level command line parsing problems"
  echo "cypress:server:args         Incorrect parsed command line arguments"
  echo "cypress:server:specs        Not finding the expected specs"
  echo "cypress:server:project      Opening the project"
  echo "cypress:server:browsers     Finding installed browsers"
  echo "cypress:launcher            Launching the found browser"
  echo "cypress:network:*           Adding network interceptors"
  echo "cypress:net-stubbing*       Network interception in the proxy layer"
  echo "cypress:server:reporter     Problems with test reporters"
  echo "cypress:server:preprocessor Processing specs"
  echo "cypress:server:plugins      Running the plugins file and bundling specs"
  echo "cypress:server:socket-e2e   Watching spec files"
  echo "cypress:server:task         Invoking the cy.task() command"
  echo "cypress:server:socket-base  Debugging cy.request() command"
  echo "cypress:webpack             Bundling specs using webpack"
  exit 1
}

SPECS_FOLDER="cypress/integration/**/*"
PROFILE="member"

if [[ "$1" == "--help" ]]; then
  help_me
else
  while [[ $# -gt 0 ]]
  do
    key="$1"

    case $key in
        -h|--host)
        HOST="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--profile)
        PROFILE="$2"
        shift # past argument
        shift # past value
        ;;
        -d|--debug)
        DEBUG="$2"
        shift # past argument
        shift # past value
        ;;
        *)    # test folder
        SPECS_FOLDER="cypress/integration/$1.js"
        shift # past argument
        ;;
    esac
  done
fi

# find the host if nothing was given
if [[ -z "${HOST}" ]]; then
  if [ -f "/usr/local/bin/wb" ]; then
    # this runs only in workspaces!!!
    APP_PORT=$(wb elektra 'echo $APP_PORT' | tail -1 | tr -d '\r')
    echo "APP_PORT      => $APP_PORT"
    HOST="http://localhost:$APP_PORT"
  fi

  if [[ -z "${APP_PORT}" ]]; then
    echo "Error: no APP_PORT found"
    help_me
  fi
fi

if [[ -z "${HOST}" ]]; then
  echo "Error: no HOST found"
  help_me
fi

set -o allexport; source ../.env; set +o allexport

TEST_USER=$TEST_MEMBER_USER
TEST_PASSWORD=$TEST_MEMBER_PASSWORD

if [[ "${PROFILE}" == "admin" ]]; then
  TEST_USER=$TEST_ADMIN_USER
  TEST_PASSWORD=$TEST_ADMIN_PASSWORD
fi

# show all hidden chars for debugging
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# echo $HOST | cat -A

echo "HOST          => $HOST"
echo "TEST_PATH     => $PWD"
echo "SPECS_FOLDER  => $SPECS_FOLDER"
echo "PROFILE       => $PROFILE"
echo "TEST_DOMAIN   => $TEST_DOMAIN"
echo "TEST_USER     => $TEST_USER"
if [[ -n "$DEBUG" ]]; then
  echo "DEBUG:        => $DEBUG"
fi
echo ""

docker run --rm -it \
  --volume "$PWD:/e2e" \
  --workdir /e2e \
  --env DEBUG="$DEBUG" \
  --env CYPRESS_BASE_URL="$HOST" \
  --env CYPRESS_TEST_PASSWORD="$TEST_PASSWORD" \
  --env CYPRESS_TEST_USER="$TEST_USER" \
  --env CYPRESS_TEST_DOMAIN="$TEST_DOMAIN" \
  --network=host \
  keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/cypress/included:7.1.0 --spec "$SPECS_FOLDER"
