describe("flavors", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open flavor page in member project", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/compute/flavors`)
    cy.contains('[data-test=page-title]','Flavors')
  })

})