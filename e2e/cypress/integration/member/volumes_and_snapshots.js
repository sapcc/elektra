describe("volumes", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/block-storage/?r=/volumes`)
  })

  it("the volumes page is reachable", () => {
    cy.contains('[data-test=page-title]','Volumes & Snapshots')
    cy.get(".table.volumes")
    cy.request("/").should((response) => {
      expect(response.status).to.eq(200)
    })
  })

  it("click on 'Create New' button opens a modal window", () => {
    cy.get(".btn").contains("Create New").click()
    cy.url().should("include", "/?r=/volumes/new")
    cy.get(".modal-content").as("modal")

    cy.get("@modal").contains("New Volume")
    cy.get("@modal").contains("Save")
  })
})

describe("snapshots", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(
      `/${Cypress.env("TEST_DOMAIN")}/test/block-storage/?r=/snapshots`
    )
  })

  it("the snapshots page is reachable", () => {
    cy.contains('[data-test=page-title]','Volumes & Snapshots')
    cy.get(".table.snapshots")
    cy.request(
      `/${Cypress.env("TEST_DOMAIN")}/test/block-storage/?r=/snapshots`
    ).should((response) => {
      expect(response.status).to.eq(200)
    })
  })
})

describe("deep links", () => {
  it("opens the new volume modal window", () => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(
      `/${Cypress.env("TEST_DOMAIN")}/test/block-storage/?r=/volumes/new`
    )
    cy.contains('[data-test=page-title]','Volumes & Snapshots')
    cy.get(".modal-content").as("modal")
    cy.get("@modal").contains("New Volume")
    cy.get("@modal").contains("Save")
  })
})
