describe("project landing page", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open project landing page and cannot see edit project button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.contains("This project is used by TEST_D021500_TM user for elektra e2e tests")
    cy.get('div.dropdown.header-action').should('not.exist')
  })

  it("open project landing page and see project wizard", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.contains("Welcome to your new Project")
    cy.contains("h4","Project")
    cy.contains("This Project is not ready for use.")
    cy.get('div.wizard-step').contains("h4","Masterdata")
    cy.get('div.wizard-step').contains("Was successfully maintained.")
    cy.get('div.wizard-step').contains("h4","Resource Quotas")
    cy.get('div.wizard-step').contains("This project already has quota.")
    cy.get('div.wizard-step').contains("h4","Resource Pooling")
    // note .should('be.disabled') works not with a or div tag!
    // https://github.com/cypress-io/cypress/issues/5903
    cy.contains("a.btn","Enable resource pooling").should('have.attr', 'disabled');
    cy.get('div.wizard-step').contains("h4","Configure Your Network")
  })

  it("open project landing page and check user profile and SSH keys", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Profile').click()
    // check not in one string because it can be different order
    cy.contains('td','dns_webmaster')
    cy.contains('td','dns_viewer')
    cy.contains('td','member')
    cy.contains('td','reader')
    cy.contains('button','Close').click()

    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Key Pairs').click()
    cy.contains('a.btn','Create new').click()
    cy.contains('h4','New Keypair')
    cy.get('input#keypair_name').type('test')
    cy.get('textarea#keypair_public_key').type('test')
    cy.contains('button','Save').click()
    cy.contains('Public key test is not a valid ssh public key')
    cy.contains('button','Cancel').should('be.visible').then(($btn) => {
      cy.wrap($btn).click()
    })
  })

  it("open project landing page and check logout button", () => {
    cy.contains('a.navbar-identity','Technical User').click()
    cy.contains('a','Log out').click()
    // check not in one string because it can be different order
    cy.contains('SAP Converged Cloud')
    cy.contains('a','Enter the cloud')
  })

})
