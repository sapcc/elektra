describe("domain landing page", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open reverse lookup  page and search for elektra test vm", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/lookup/reverselookup`)
    cy.contains("[data-test=page-title]", "Find Project")
    cy.get("#reverseLookupValue").type("elektra-test-vm (do not delete){enter}")
    cy.contains("Could not load object")
    cy.get("#reverseLookupValue").type(
      "{selectall}0b327741-8e12-4e92-b9ad-edf7a5d0594d{enter}"
    )
    cy.contains("elektra-test-vm (do not delete)")
  })
})
