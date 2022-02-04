describe("Landing page", () => {
  before(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("Open project start site and edit project description", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.get('div.dropdown.header-action').click()
    cy.get(`a[href*="${Cypress.env("TEST_DOMAIN")}/member/masterdata-cockpit/project/edit_project?load_project_root=true"]`).click()
    cy.contains('h4','Edit Project')
    let currenDate = Date.now()
    cy.get('#project_description').type(`{selectall}This project is used by TEST_D021500_TM user for elektra e2e tests{enter}added by e2e test ${currenDate}`)
    cy.contains('button','Update').click()
    cy.contains('Update was successfully')
    cy.contains(`tests added by e2e test ${currenDate}`)
  })

})
