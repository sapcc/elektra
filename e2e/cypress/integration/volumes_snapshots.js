describe("Volumes", () => {
  before(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/block-storage/?r=/volumes`)
  })

  it("The Volumes page is reachable", () => {
    cy.get(".table.volumes")
    cy.request("/").should((response) => {
      expect(response.status).to.eq(200)
    })
  })

  it("contains 'Create New' button", () => {
    cy.get(".btn").contains("Create New")
  })

  it("click on 'Create New' button opens a modal window", () => {
    cy.get(".btn").contains("Create New").click()
    cy.url().should("include", "/?r=/volumes/new")
    cy.get(".modal-content").as("modal")

    cy.get("@modal").contains("New Volume")
    cy.get("@modal").contains("Save")
  })
})

describe("Snapshots", () => {
  before(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(
      `/${Cypress.env("TEST_DOMAIN")}/member/block-storage/?r=/snapshots`
    )
  })

  it("The Snapshots page is reachable", () => {
    cy.get(".table.snapshots")
    cy.request(
      `/${Cypress.env("TEST_DOMAIN")}/member/block-storage/?r=/snapshots`
    ).should((response) => {
      expect(response.status).to.eq(200)
    })
  })
})

describe("Deep links", () => {
  it("opens the new volume modal window", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(
      `/${Cypress.env("TEST_DOMAIN")}/member/block-storage/?r=/volumes/new`
    )
    cy.get(".modal-content").as("modal")
    cy.get("@modal").contains("New Volume")
    cy.get("@modal").contains("Save")
  })
})
