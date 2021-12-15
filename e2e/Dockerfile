# https://github.com/cypress-io/cypress-docker-images/tree/master/included#cypressincluded
FROM keppel.eu-de-1.cloud.sap/ccloud-dockerhub-mirror/cypress/included:9.1.1
# https://github.com/cypress-io/cypress-docker-images
# https://hub.docker.com/r/cypress/browsers
# https://github.com/cypress-io/cypress-docker-images/tree/master/browsers#naming-scheme

# install sorry cypress wrapper
# https://docs.sorry-cypress.dev/guide/get-started#install-cy2-and-cypress
RUN npm install -g cy2 && cy2 info
ENV chrome="94"
ENV firefox="93"
ENV electron="94"
