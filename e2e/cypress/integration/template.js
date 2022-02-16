describe("template", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open template page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/template`)
    cy.contains('[data-test=page-title]','Template')
  })

})