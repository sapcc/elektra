describe("shared object storage", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open object storage and see that I need one of the respective roles", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/object-storage/swift`)
    cy.contains("[data-test=page-title]", "Object Storage")
    cy.contains(
      "Object Storage can only be used when your user account has the admin or objectstore_admin or objectstore_viewer role for this project."
    )
  })
})
