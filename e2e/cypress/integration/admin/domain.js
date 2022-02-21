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

  it("open domain landing page and check logout button", () => {
    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Log out').click()
    // check not in one string because it can be different order
    cy.contains('SAP Converged Cloud')
    cy.contains('a','Enter the cloud')
  })

  it("open domain landing page open and create project dialog", () => {
    cy.contains('a','Create a New Project').click()
    cy.contains('h4','Create new project')
    cy.get('input[name="commit"]').click()
    cy.contains('Name: Name should not be empty')
  })

  it("open domain landing page and check my requests", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','My Requests').click()
    cy.contains('[data-test=page-title]','My Requests')
  })

  it("open domain landing page and check masterdata", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Masterdata').click()
    cy.contains('[data-test=page-title]','Domain Masterdata')
    cy.contains('Complete')
  })

  it("open domain landing page and check cost report", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Cost Report').click()
    cy.contains('[data-test=page-title]','Cost Report for cc3test')
    cy.contains('text.label','network')
  })

  it("open domain landing page and check group management", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Group Management').click()
    cy.contains('[data-test=page-title]','Groups')
    cy.contains('a','CC3TEST_API_SUPPORT').click()
    cy.contains('[data-test=page-title]','Groups / CC3TEST_API_SUPPORT')
  })

  it("open domain landing page and check user management", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','User Management').click()
    cy.contains('[data-test=page-title]','Users')
    cy.get('#filter_users').type('d058266')
    cy.contains('Hans-Georg Winkler')
  })

})


