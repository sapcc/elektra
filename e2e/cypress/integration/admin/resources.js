describe("Resource Management - Project Level", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("Start page is reachable, and you can see the project settings", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/resources/project`)
    cy.contains('div','Members per Server Group')
    cy.get('a[href*="#/compute/settings"]').click()
    cy.contains('h4','Project Settings')
  })
  
  it("Network page is reachable, and you can edit and check DNS quota", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/resources/project#/dns`)
    cy.contains('div','Recordsets per Zone')
    cy.get('a[href*="#/dns/edit/dns"]').click()
    cy.get('input.form-control:first').type('{selectall}30{enter}')
    cy.get('button').contains('Check').click()
    cy.get('div.text-success').contains('Quota can be raised without approval')
    cy.get('button').contains('Submit')
    cy.get('button').contains('Cancel').click()
  })

})