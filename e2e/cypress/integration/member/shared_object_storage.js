describe("shared object storage", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open object storage and see that I need admin or swiftoperator role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/object-storage/`)
    cy.contains('[data-test=page-title]','Object Storage')
    cy.contains('Object Storage can only be used when your user account has the admin or swiftoperator role for this project.')
  })

})