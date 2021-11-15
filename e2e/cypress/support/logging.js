// use own logging to write to stdout
// https://github.com/cypress-io/cypress/issues/3199#issuecomment-529430701
Cypress.Commands.overwrite('log', (subject, message) => cy.task('log', message));