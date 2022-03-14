describe("load balancing", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open load balancer page and test new Load Balancer button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/lbaas2/?r=/loadbalancers`)
    cy.contains('[data-test=page-title]','Load Balancers')
  })

})