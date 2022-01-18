describe("Instances", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/compute/instances`)
  })

  it("The Instances page is reachable", () => {
    cy.get(".table.instances")
    cy.contains("Servers")
    cy.request(
      `/${Cypress.env("TEST_DOMAIN")}/member/compute/instances`
    ).should((response) => {
      expect(response.status).to.eq(200)
    })
    cy.get(".btn").contains("Create New")
  })

  it("click on 'Create New' button opens a modal window", () => {
    cy.get(".btn").contains("Create New").click()
    cy.url().should("include", "instances?overlay=new")
    cy.get("button.btn.btn-primary").contains("Create")
  })
})
