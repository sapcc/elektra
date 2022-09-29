describe("load balancing", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("rails loads the plugin", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/lbaas2/?r=/loadbalancers`)
    cy.contains("[data-test=page-title]", "Load Balancers")
  })

  it("react can load the basics", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/lbaas2/?r=/loadbalancers`)
    // test at least one tab is loaded
    cy.get("[data-target='tab-0']").should("have.lengthOf", 1)
    // test the table is being loaded
    cy.get("[data-target='table-loadbalancers']").should("have.lengthOf", 1)
  })

  it("the test lb can be found", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/lbaas2/?r=/loadbalancers`)
    // search in input
    cy.get("input[data-test='search']").type("elektra_e2e_test_do_not_delete")
    // check if the table has the entry
    cy.contains("elektra_e2e_test_do_not_delete")
  })

  it("the the basic objects can be displayed", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/lbaas2/?r=/loadbalancers`)
    // search in input
    cy.get("input[data-test='search']").type("elektra_e2e_test_do_not_delete")
    // check if the table has the entry
    cy.contains("elektra_e2e_test_do_not_delete").click()
    // check listener is displayed
    cy.contains("test_liste") //the whole name is being by the UI shortened
    // test pool is displayed
    cy.contains("test_pool") //the whole name is being by the UI shortened
  })
})
