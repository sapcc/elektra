describe("shared filesystem", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open shared file system storage page and check for new button", () => {
    // use admin project because shared networks are not configured in the member project
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/shared-filesystem-storage/?r=/shares`)
    cy.contains('[data-test=page-title]','Shared File System Storage')
    cy.contains('a','Create New').click()
    cy.contains('button','Save').should('be.disabled')
    cy.get('#name').type('test')
    cy.get('#share_proto').select(1)
    cy.get('#size').type('10')
    cy.get('#share_network_id').select(1)
    cy.contains('button','Save').should('be.enabled')
    cy.contains('button','Cancel').click()
  })

})