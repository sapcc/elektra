describe("landing page", () => {
  it("loads content", () => {
    // content is loaded if children of root element exists.
    // children are built by React
    cy.request("/").should((response) => {
      expect(response.status).to.eq(200)
    })
  })

  it("user is not logged, tries to visit domain", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}`)
    cy.contains('Log in')
  }) 

  describe("Content", () => {
    before(() => {
      cy.visit("/")
    })

    it("contains Converged Cloud", () => {
      cy.contains("Converged Cloud")
    })
  })
})
