describe("kubernetes", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open kubernetes page in member project and see that I need kubernetes admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/kubernetes/`)
    cy.contains('[data-test=page-title]','Kubernetes as a Service')
    cy.contains('code','kubernetes_admin')
  })

})