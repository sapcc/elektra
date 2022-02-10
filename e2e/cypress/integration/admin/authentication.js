describe("authentication", () => {

  it("user is not logged, tries to visit domain landing and is redirected to login page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/home/`)
    cy.contains('Please sign in')
  })

  it("login admin and redirected to the requested url after login", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.location("pathname").should("eq", `/${Cypress.env("TEST_DOMAIN")}/home`)
  })

  it("login failed", () => {
    cy.elektraLogin("cc3test", "BATMAN", "BAD_PASSWORD")
    cy.contains("Invalid username/password combination.")
  })

})
