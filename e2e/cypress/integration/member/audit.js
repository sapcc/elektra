describe("audit", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open audit and should see unauthorized", () => {
    cy.request({
      url: `/${Cypress.env("TEST_DOMAIN")}/test/audit/`,
      failOnStatusCode: false
    }).should((response) => {
      expect(response.status).to.eq(401)
    })
  })

})