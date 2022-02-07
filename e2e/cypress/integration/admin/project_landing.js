describe("project landing page", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open project landing page and edit project description", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.get('div.dropdown.header-action').click()
    cy.get(`a[href*="${Cypress.env("TEST_DOMAIN")}/member/masterdata-cockpit/project/edit_project?load_project_root=true"]`).click()
    cy.contains('h4','Edit Project')
    let currenDate = Date.now()
    cy.get('textarea#project_description').type(`{selectall}This project is used by TEST_D021500_TM user for elektra e2e tests added by e2e test ${currenDate}`)
    cy.contains('button','Update').click()
    cy.contains(`added by e2e test ${currenDate}`)
  })

  it("open project start site and see project wizard", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)

    // check resource pooling setup and skip modal windows
    cy.contains("a.btn","Enable resource pooling").click()
    cy.contains('Please be aware that enabling all resource pools is a permanent change that cannot be undone!')
    cy.contains('button','Cancel').click()
    cy.get('a[href*="sharding_skip_wizard_confirm"]').click()
    cy.contains('h4','Skip resource pooling')
    cy.contains('button','Cancel').click()
    // check resource pooling setup and skip modal windows
    cy.contains("a.btn","Set Network").click()
    cy.contains('h4','Setup New Network')
    cy.contains('button','Cancel').click()
    cy.get('a[href*="network_wizard/skip_wizard"]').click()
    cy.contains('h4','Skip Network Setup for Project')
    cy.contains('button','Cancel').click()
  })

})
