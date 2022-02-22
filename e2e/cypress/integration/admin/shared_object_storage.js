describe("shared object storage", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open object storage and see that object storage is not enabled", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/object-storage/`)
    cy.contains('[data-test=page-title]','Object Storage')
    cy.contains('Object storage is not enabled for this project, yet. To enable it, request an Object Storage quota in the Resource Management tool.')
    cy.contains('a','Go to Resource Management')
  })

  it("open object storage and check create container button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/object-storage/`)
    cy.contains('[data-test=page-title]','Object Storage')
    cy.contains('a','Create container').click()
    cy.contains('Inside a project, objects are stored in containers. Containers are where you define access permissions and quotas.')
    cy.contains('button','Cancel').click()
  })

})