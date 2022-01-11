describe("Instances", () => {
  before(() => {
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
    cy.request("/").should((response) => {
      expect(response.status).to.eq(200)
    })
  })

  it("contains 'Create New' button", () => {
    cy.get(".btn").contains("Create New")
  })

  // instances?overlay=new
  it("click on 'Create New' button opens a modal window", () => {
    cy.get(".btn").contains("Create New").click()
    cy.url().should("include", "instances?overlay=new")
    cy.get(".modal-content").as("modal")

    cy.get("@modal").contains("New Instance")
    cy.get("@modal").contains("Create")
  })
})
