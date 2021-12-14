#!/bin/bash

function help_me () {

  echo "Usage: run.sh --host HOST --profile member|admin --e2e_path /path/to/e2e --browser chrome|firefox --debug CYPRESS-DEBUG-FLAG PLUGIN-TEST "
  echo "       run.sh --help                                                   # will print out this message"
  echo "       run.sh --info                                                   # prints info about used cypress"
  echo "       run.sh --host http://localhost:3000 landingpage                 # will only run landingpage tests"
  echo "       run.sh --host http://localhost:3000 --debug 'cypress:network:*' # will show debug information about the networking"
  echo "       run.sh --e2e_path                                               # this optional if not set \$PWD is used"
  echo "       run.sh --browser chrome                                         # choose browser to test (default is chrome)"
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
CY_CMD="cypress"
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
        -e2e|--e2e_path) # local path for e2e
        E2E_PATH="$1"
        shift # past argument
        shift # past value
        ;;
        -b|--browser) # local path for e2e
        BROWSER="$1"
        shift # past argument
        shift # past value
        ;;
        -i|--info) # local path for e2e
        docker run -it --rm --entrypoint=cypress cy2 info
        exit
        ;;
        -r|--record) # local path for e2e
        date=$(date)
        hostname=$(hostname)
        ci_build_id="$date - $hostname"
        CY_OPTIONS=(--record --key 'elektra' --parallel --ci-build-id "$ci_build_id")
        CY_CMD="cy2"
        CY_RECORD="https://director.cypress.qa-de-1.cloud.sap"
        shift # past argument
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

if [[ -z "${E2E_PATH}" ]]; then
  E2E_PATH=$PWD
fi

if [[ -z "${BROWSER}" ]]; then
  BROWSER="chrome"
fi

# show all hidden chars for debugging
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# echo $HOST | cat -A

echo "HOST          => $HOST"
echo "BROWSER       => $BROWSER"
echo "TEST_PATH     => $PWD"
echo "SPECS_FOLDER  => $SPECS_FOLDER"
echo "E2E_PATH      => $E2E_PATH"
echo "PROFILE       => $PROFILE"
echo "TEST_DOMAIN   => $TEST_DOMAIN"
echo "TEST_USER     => $TEST_USER"
if [[ -n "$CY_RECORD" ]]; then
  echo "RECORD        => $CY_RECORD"
fi
if [[ -n "$DEBUG" ]]; then
  echo "DEBUG:        => $DEBUG"
fi
echo ""

docker run --rm -it \
  --volume "$E2E_PATH:/e2e" \
  --workdir "/e2e" \
  --env DEBUG="$DEBUG" \
  --env CYPRESS_BASE_URL="$HOST" \
  --env CYPRESS_TEST_PASSWORD="$TEST_PASSWORD" \
  --env CYPRESS_TEST_USER="$TEST_USER" \
  --env CYPRESS_TEST_DOMAIN="$TEST_DOMAIN" \
  --env CYPRESS_API_URL=$CY_RECORD \
  --entrypoint $CY_CMD \
  --network=host \
  cy2 run "${CY_OPTIONS[@]}" --spec "$SPECS_FOLDER" --browser $BROWSER
