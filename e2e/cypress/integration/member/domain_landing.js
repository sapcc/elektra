describe("domain Landing page", () => {
  before(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open domain landing page and test search for project member", () => {
    cy.get(".title-content").contains("Home")
    cy.get('#search-input').type('member')
    cy.contains('a','member').click()
    cy.contains("This project is used by TEST_D021500_TM user for elektra e2e tests")
  })
})
