describe("resource management - project level", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("start page is reachable, and you can see the project settings", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/resources/project`)
    cy.contains("[data-test=page-title]", "Manage Project Resources")
    cy.contains("div", "Members per Server Group")
  })
})
