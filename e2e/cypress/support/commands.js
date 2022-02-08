// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

Cypress.Commands.add("elektraLogin", (domain, user, password) => {

  cy.visit(`/cc3test/auth/login/${domain}?after_login=%2F${domain}%2Fhome`)
  cy.get("#username").type(user)
  cy.get("#password").type(password, { log: false })
  cy.get('button[type="submit"]').click()

  // accept terms of use if not already accepted
  // to test you need to delete the tos entry in the DB
  // logon to rails console with "bin/rails c"
  // get the user you want with "UserProfile.first.domain_profiles"
  // delete the profile with "UserProfile.second.domain_profiles.delete_all"
  cy.get("body").then(($body) => {
    if($body.find('input#accept_tos').length > 0) {
      cy.get('input#accept_tos').check()
      cy.get("input").contains("Accept").click()
    }
  })
})
