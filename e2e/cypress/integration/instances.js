describe("Instances", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/compute/instances`)
  })


  it("The Instances page is reachable and you can see VM with title 'elektra-test-vm' ", () => {
    cy.get(".table.instances")
    cy.contains("Servers")
    cy.contains("Create New")

    cy.get("#search")
      .should('be.visible')
      .type('elektra{enter}')
    
    cy.contains("elektra-test-vm").click()
    // because wrong SSL we test 400 from Hermes 
    cy.get('span.guest_tools_problem').should('be.visible')
    cy.get('span.guest_tools_problem_text').should('contain','Problem to get')

  })

  it("click on 'Create New' button opens a modal window", () => {
    cy.get(".btn").contains("Create New").click()
    cy.url().should("include", "instances?overlay=new")
    cy.get("button.btn.btn-primary").contains("Create")
  })

})
