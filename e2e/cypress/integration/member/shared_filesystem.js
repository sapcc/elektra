describe("shared filesystem", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open shared file system storage page and check for new button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/shared-filesystem-storage/?r=/shares`)
    cy.contains('[data-test=page-title]','Shared File System Storage')
    cy.contains('Create New')
  })

})