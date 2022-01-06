// @javascript
// Feature: Instances
//   Background:
//     Given I visit domain path "home"
//     And I log in as test_user
//     Given Test user has accepted terms of use
//     Then I am redirected to domain path "home"

//   Scenario: The Instances page is reachable
//     When I visit project path "compute/instances"
//     Then the page status code is successful
//     And I see "Create new" button
//     When I click on "Create new"
//     Then the page status code is successful
//     #And I see "Max count"

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

  // it("click on 'Create New' button opens a modal window", () => {
  //   cy.get(".btn").contains("Create New").click()
  //   cy.url().should("include", "/?r=/volumes/new")
  //   cy.get(".modal-content").as("modal")

  //   cy.get("@modal").contains("New Volume")
  //   cy.get("@modal").contains("Save")
  // })
})
