describe("Authentication", () => {
  it("Login user", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.location("pathname").should("eq", `/${Cypress.env("TEST_DOMAIN")}/home`)
  })

  it("Login failed", () => {
    cy.elektraLogin("cc3test", "BATMAN", "BAD_PASSWORD")
    cy.contains("Invalid username/password combination.")
  })
})
