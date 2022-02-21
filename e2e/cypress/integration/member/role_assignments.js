describe("role assignments", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open user role assignments page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/projects/role-assignments`)
    cy.contains('[data-test=page-title]','Authorizations')
    cy.get('[data-test=search]').type('TEST_D021500_TM')
    cy.contains('Technical User TEST_D021500_TM')
    cy.contains('button','Add New Member').should('not.exist')
  })

  it("open user role assignments page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/projects/role-assignments?active_tab=groupRoles`)
    cy.contains('[data-test=page-title]','Authorizations')
    cy.contains('No group role assignments for this project yet')
    cy.contains('button','Add New Member').should('not.exist')
  })

})