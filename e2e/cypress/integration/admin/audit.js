describe("audit", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open audit log page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/audit/`)
    cy.contains('[data-test=page-title]','Audit Log')
    cy.contains('label','Filter')
  })

})