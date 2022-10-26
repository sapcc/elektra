describe("masterdata", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open masterdata", () => {
    cy.request({
      url: `/${Cypress.env("TEST_DOMAIN")}/test/masterdata-cockpit/project`,
      failOnStatusCode: false,
    }).should((response) => {
      expect(response.status).to.eq(403)
    })
  })
})
