#!/bin/bash

# this script is only for using in workspaces!!!
APP_PORT=$(wb elektra 'echo $APP_PORT' | tail -1)
HOST="http://localhost:$APP_PORT"
SPECS_FOLDER="cypress/integration/**/*"

echo "APP_PORT: $APP_PORT"
echo "HOST: $HOST"
echo "SPECS_FOLDER: $SPECS_FOLDER"

docker run --rm -it -v "$PWD:/e2e" -w /e2e --network=host -e CYPRESS_baseUrl="$HOST" keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/cypress/included:7.1.0 --spec "$SPECS_FOLDER"
