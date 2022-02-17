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

  /*
  it("open domain landing page and check cost report", () => {
    // TODO: there is in widget.js:31 Uncaught (in promise) TypeError: Cannot read properties of null (reading 'attributes')
    // https://stackoverflow.com/questions/53845493/cypress-uncaught-assertion-error-despite-cy-onuncaughtexception
    // ignore browser error 
    Cypress.on('uncaught:exception', () => {
      return false;
    });
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Cost Report').click()
    cy.contains('[data-test=page-title]','Cost Report for cc3test')
    cy.contains('text.label','network')
  })

  it("open domain landing page and check group management", () => {
    // TODO: there is in widget.js:31 Uncaught (in promise) TypeError: Cannot read properties of null (reading 'attributes')
    // ignore browser error 
    Cypress.on('uncaught:exception', () => {
      return false;
    });
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Group Management').click()
    cy.contains('[data-test=page-title]','Groups')
    cy.contains('a','CC3TEST_API_SUPPORT').click()
    cy.contains('[data-test=page-title]','Groups / CC3TEST_API_SUPPORT')
  })

  it("open domain landing page and check user management", () => {
    // TODO: there is in widget.js:31 Uncaught (in promise) TypeError: Cannot read properties of null (reading 'attributes')
    // ignore browser error 
    Cypress.on('uncaught:exception', () => {
      return false;
    });
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','User Management').click()
    cy.contains('[data-test=page-title]','Users')
    cy.get('#filter_users').type('d058266')
    cy.contains('Hans-Georg Winkler')
  })
  */
  it("open domain landing page and search Child Objects for elektra test vm", () => {
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Find by Child Objects').click()
    // TODO: rename to Find Object!
    cy.contains('Find Project')
    cy.get('#reverseLookupValue').type('elektra-test-vm (do not delete){enter}')
    cy.contains('Could not load object (Request failed with status code 404)')
    cy.get('#reverseLookupValue').type('{selectall}df628236-e1a5-4dcd-9715-e204e184fe71{enter}')
    cy.contains('elektra-test-vm (do not delete)')
  })

})


