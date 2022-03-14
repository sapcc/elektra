describe("role assignments", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open user role assignments page and check role options", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/identity/projects/role-assignments`)
    cy.contains('[data-test=page-title]','Authorizations')
    // TODO: CypressError: `cy.type()` can only be called on a single element. Your subject contained 2 elements.
    //cy.get('[data-test=search]').type('TEST_D021500_TA')
    //cy.contains('Technical User TEST_D021500_TA')
    //cy.contains('button','Edit').should('be.visible').click()
    //cy.contains('admin (Keystone Administrator)')
    //cy.contains('button','Cancel').click()
  })

  it("open user role assignments page and check new member button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/identity/projects/role-assignments`)
    cy.contains('[data-test=page-title]','Authorizations')
    cy.contains('button','Add New Member').click()
    // TODO check user search
  })

  it("open group role assignments page and check new member button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/identity/projects/role-assignments?active_tab=groupRoles`)
    cy.contains('[data-test=page-title]','Authorizations')
    // TODO there are two buttons so this is not working 
    // This element `<button.btn.btn-primary>` is not visible because its parent `<div#item_payload-pane-userRoles.tab-pane.fade>` has CSS property: `display: none`
    // cy.contains('button','Add New Member').should('be.visible').click()
    // TODO check group search
  })

})