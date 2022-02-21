
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
    cy.contains('[data-test=page-title]','Find Project')
    cy.get('#reverseLookupValue').type('elektra-test-vm (do not delete){enter}')
    cy.contains('Could not load object (Request failed with status code 404)')
    cy.get('#reverseLookupValue').type('{selectall}df628236-e1a5-4dcd-9715-e204e184fe71{enter}')
    cy.contains('elektra-test-vm (do not delete)')
  })

})