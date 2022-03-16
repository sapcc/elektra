describe("cost report", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open cost report and see report for network and virtualMachine", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/reports/cost/project`)
    cy.contains('[data-test=page-title]','Cost Report')
    cy.contains('text.label','network')
    cy.contains('text.label','virtualMachine')
  })

  it("open domain landing page and check cost report", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/home`)
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Cost Report').click()
    cy.contains('[data-test=page-title]','Cost Report for cc3test')
    cy.contains('text.label','network')
  })

})