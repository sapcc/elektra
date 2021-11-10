#!/bin/bash

function help_me () {
  echo "Usage: run.sh ELEKTRA_HOST*"
  echo "       run.sh --help will print out this message"
  echo "Note: if you run this on our workspaces with installed elektra env you can just use 'run.sh'"
  echo "      the script will figure out where elektra is runing"
  exit 1
}

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
        *)    # test folder
        SPECS_FOLDER="cypress/integration/$2/*"
        shift # past argument
        ;;
    esac
  done

fi

if [[ -z "${HOST}" ]]; then
  if [ -f "/usr/local/bin/wb" ]; then
    # this runs in workspaces!!!
    APP_PORT=$(wb elektra 'echo $APP_PORT' | tail -1 | tr -d '\r')
    echo "APP_PORT: $APP_PORT"
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

SPECS_FOLDER="cypress/integration/**/*"
echo "HOST: $HOST"
echo "SPECS_FOLDER: $SPECS_FOLDER"

docker run --rm -it -v "$PWD:/e2e" -w /e2e -e CYPRESS_baseUrl="$HOST" keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/cypress/included:7.1.0 --spec "$SPECS_FOLDER"
