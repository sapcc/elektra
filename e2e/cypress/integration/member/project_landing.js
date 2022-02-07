describe("project landing page", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open project start site and cannot see edit project button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.contains("This project is used by TEST_D021500_TM user for elektra e2e tests")
    cy.get('div.dropdown.header-action').should('not.exist')
  })

  it("open project start site and see project wizard", () => {
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

})
