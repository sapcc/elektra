describe("project landing page", () => {
  before(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open project start site and cannot see edit project button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.contains("Project Overview")
    cy.contains("This project is used by TEST_D021500_TM user for elektra e2e tests")
    cy.get('div.dropdown.header-action').should('not.exist')
  })
})
