describe("Load Balancing", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open load balancer page and test new Load Balancer button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/lbaas2/?r=/loadbalancers`)
    cy.contains('[data-test=page-title]','Load Balancers')
    cy.contains('No loadbalancers found.')
    cy.contains('a','New Load Balancer').click()
    cy.get('#contained-modal-title-lg').contains('New Load Balancer')
    cy.contains('button.btn','Cancel').click()
  })

})