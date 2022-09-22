describe("key_manager", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open key manager and check new secret button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/key-manager/secrets`)
    cy.contains("[data-test=page-title]", "Key Manager")
    cy.contains("a.btn", "New Secret").click()
    cy.contains("New Secret")
    cy.contains("button", "Create").click()
    cy.contains("Name: can't be blank")
  })

  it("open key manager and check elektra-test secret", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/key-manager/secrets`)
    cy.get(".secrets_table table tbody a").first().click()
    cy.contains("Secret details")
  })

  it("open key manager and check new container button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/key-manager/containers`)
    cy.contains("a.btn", "New Container").click()
    cy.contains("New Container")
    cy.contains("button", "Create").click()
    cy.contains("Name: can't be blank")
  })

  it("open key manager and check elektra-test-container", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/key-manager/containers`)
    cy.get(".secrets_table table tbody a").first().click()
    cy.contains("Container details")
  })
})
