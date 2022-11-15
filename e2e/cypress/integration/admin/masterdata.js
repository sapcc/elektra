describe("masterdata", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open masterdata", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/masterdata-cockpit/project`)
    cy.contains('[data-test=page-title]','Project Masterdata')
    cy.contains('Masterdata Status')
  })

  it("open masterdata and check edit project", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/masterdata-cockpit/project`)
    cy.contains('[data-test=page-title]','Project Masterdata')
    cy.get('#edit_project_btn').click()
    cy.contains('Edit Project')
    cy.contains('button','Cancel').click()
  })

  it("open masterdata and check edit masterdata", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/masterdata-cockpit/project`)
    cy.contains('[data-test=page-title]','Project Masterdata')
    cy.get('#edit_masterdata_btn').click()
    cy.contains('Edit masterdata for project: admin')
    cy.contains('button','Cancel').click()
  })

  it("open domain landing page and check masterdata", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/home`)
    cy.contains('[data-test=page-title]','Home')
    cy.contains('a','Masterdata').click()
    cy.contains('[data-test=page-title]','Domain Masterdata')
    cy.contains('a','Edit').click()
    cy.contains('Edit masterdata for domain: cc3test')
  })

})
