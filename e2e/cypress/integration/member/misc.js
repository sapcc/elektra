describe("miscellaneous", () => {

  it("load member project via id shortcut", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )

    cy.visit("/_/440a7be0551347fb97db4665f03585dd")
    cy.contains("440a7be0551347fb97db4665f03585dd")
    cy.contains("This project is used by TEST_D021500_TM user for elektra e2e")
  })

  it("load elektra test vm via id shortcut", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )

    cy.visit("/_jump_to/df628236-e1a5-4dcd-9715-e204e184fe71")
    cy.contains("df628236-e1a5-4dcd-9715-e204e184fe71")
    cy.contains("elektra-test-vm")
  })

  it("load metrics", () => {
    cy.request("/metrics")
      .its('status')
      .should('eq', 200)
  })
})