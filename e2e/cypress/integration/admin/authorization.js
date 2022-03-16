describe("user role assignments", () => {
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
    cy.get('[data-test=search]').eq(0).type('TEST_D021500_TA')
    cy.contains('Technical User TEST_D021500_TA')
    cy.contains('button','Edit').should('be.visible').click()
    cy.contains('admin (Keystone Administrator)')
    cy.contains('button','Cancel').click()
  })

  it("open user role assignments page and check new member button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/identity/projects/role-assignments`)
    cy.contains('[data-test=page-title]','Authorizations')
    cy.contains('button','Add New Member').click()
    cy.get('input[placeholder*="User name or ID"]').type('d058266')
    cy.contains('Hans-Georg Winkler')
  })

  it("open domain landing page and check user management", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/home`)
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','User Management').click()
    cy.contains('[data-test=page-title]','Users')
    cy.get('#filter_users').type('d058266')
    cy.contains('Hans-Georg Winkler')
  })

})

describe("group role assignments", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })
  
  it("open group role assignments page", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/identity/projects/role-assignments?active_tab=groupRoles`)
    cy.contains('[data-test=page-title]','Authorizations')
  })

  it("open domain landing page and check group management", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/home`)
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Group Management').click()
    cy.contains('[data-test=page-title]','Groups')
    cy.contains('a','CC3TEST_API_SUPPORT').click()
    cy.contains('[data-test=page-title]','Groups / CC3TEST_API_SUPPORT')
  })


})