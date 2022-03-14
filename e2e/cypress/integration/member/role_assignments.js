describe("role assignments", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open user role assignments page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/identity/projects/role-assignments`)
    cy.contains('[data-test=page-title]','Authorizations')
    cy.contains('Technical User TEST_D021500_TM')
    cy.contains('button','Add New Member').should('not.exist')
  })

  it("open user role assignments page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/identity/projects/role-assignments?active_tab=groupRoles`)
    cy.contains('[data-test=page-title]','Authorizations')
    cy.contains('Converged Cloud cc3test Domain Administrators')
    cy.contains('button','Add New Member').should('not.exist')
  })

})