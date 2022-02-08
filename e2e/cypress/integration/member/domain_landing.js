describe("domain landing page", () => {
  beforeEach(() => {
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

  it("open domain landing page and check user profile", () => {
    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Profile').click()
    // check not in one string because it can be different order
    cy.contains('td','monitoring_viewer')
    cy.contains('td','reader')
    cy.contains('td','member')
  })
})
