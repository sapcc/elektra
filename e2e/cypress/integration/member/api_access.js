describe("api endpoints", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/projects/api-endpoints`)
  })

  it("the api endpoints for clients page reachable", () => {
    cy.contains('Here you can find the parameters needed to access the project with an openstack client.')
    cy.contains('a.btn','Download Openstack RC File')
    cy.contains('a.btn','Download Openstack RC File for Windows PowerShell')
  })

})

describe("web shell", () => {

  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open web shell", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/webconsole/`)
    cy.contains('a','Web Shell')
  })

  it("open web shell on toolbar", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/identity/project/home`)
    cy.get('[data-trigger="webconsole:open"]').click()
    cy.contains('div.toolbar','Web Shell')
  })

})
