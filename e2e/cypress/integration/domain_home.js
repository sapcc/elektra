require("../support/commands")

describe("Landing page", () => {
  before(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("contains home breadcrumb", () => {
    cy.get(".title-content").contains("Home")
  })
})
