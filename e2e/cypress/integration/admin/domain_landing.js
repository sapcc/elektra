describe("domain landing page", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open domain landing page and check user profile", () => {
    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Profile').click()
    // check not in one string because it can be different order
    cy.contains('td','member')
    cy.contains('td','reader')
    cy.contains('td','admin')
  })

  it("open domain landing page open and create project dialog", () => {
    cy.contains('a','Create a New Project').click()
    cy.contains('h4','Create new project')
    cy.get('input[name="commit"]').click()
    cy.contains('Name: Name should not be empty')
  })
})
