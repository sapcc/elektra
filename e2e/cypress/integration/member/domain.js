describe("domain landing page", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/home`)
  })

  it("open domain landing page and check user profile", () => {
    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Profile').click()
    // check not in one string because it can be different order
    cy.contains('td','reader')
    cy.contains('td','member')
  })

  /*
  // this is not working because the test user is seeing only 4 projects so the search is not available
  it("open domain landing page and test search for project member", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.get('#search-input').type('test')
    cy.contains('a','test').click()
    cy.contains("Test Project")
  })

  // this is not working because the test user is seeing only 4 projects so the search is not available
  it("open domain landing page and check project lists search", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.get('#projects_list > a').click()
    cy.contains('Your Projects')
    // search is being covered by another element -> {force: true}
    cy.get('#search-input').type('test',{force: true})
    // <a>admin</a> is being covered by another element -> {force: true}
    cy.contains('a','test').should('be.visible').click({force: true})
    cy.contains("Test Project")
  })
  */

  it("open domain landing page and test create project request", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Request a New Project').click()
    cy.contains("Request new project")
    cy.contains('input','Create').click()
    cy.contains('span.help-block','Name should not be empty')
    cy.contains('button','Cancel').click()
  })

  it("open domain landing page and test check my requests", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','My Requests').click()
    cy.contains('[data-test=page-title]','My Requests')
  })

})
