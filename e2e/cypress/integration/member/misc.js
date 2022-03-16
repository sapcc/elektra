describe("miscellaneous", () => {

  it("load member project via id shortcut", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )

    cy.visit("/_/d940aae3f8084f15a9b67de5b3b39720")
    cy.contains("d940aae3f8084f15a9b67de5b3b39720")
    cy.contains("Test Project")
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