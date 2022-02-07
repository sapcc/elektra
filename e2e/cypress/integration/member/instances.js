describe("instances", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
    
  })


  it("the instances page is reachable and you can search for VM with title 'elektra-test-vm' and show it's details", () => {

    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/compute/instances`)
    cy.get("#search")
      .should('be.visible')
      .type('elektra{enter}')
    
    cy.contains("elektra-test-vm").click()
    cy.contains('h4','Show Instance')
    cy.contains('td','elektra-test-vm (do not delete)');
    // because wrong SSL we test 400 from Hermes 
    // cy.get('span.guest_tools_problem').should('be.visible')
    // cy.get('span.guest_tools_problem_text').should('contain','Problem to get')

  })

  it("click on 'Create New' button opens a modal window", () => {

    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/compute/instances`)
    cy.contains("Create New")
    cy.get(".btn").contains("Create New").click()
    cy.url().should("include", "instances?overlay=new")
    cy.contains('label','Name')
    cy.get("button.btn.btn-primary").contains("Create")

  })

  it("the dropdown menu for 'elektra-test-vm' is available and menus are working", () => {

    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/compute/instances?searchfor=Name&search=elektra`)
    
    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Edit').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('label','Name')
    cy.contains('button','Cancel').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Attach Floating IP').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('h4','Attach Floating IP')
    cy.contains('button','Cancel').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Detach Floating IP').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('label','Address')
    cy.contains('button','Cancel').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Attach Interface').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('label','Network')
    cy.contains('button','Cancel').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Detach Interface').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('label','Address')
    cy.contains('button','Cancel').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Resize').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('label','Old flavor')
    cy.contains('button','Cancel').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Create Snapshot').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('you need the image_admin and swiftoperator role')
    cy.get('#mainModal button[type="button"]').click()

    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Stop').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('Are you sure you want to stop this instance?')
    cy.contains('a.btn','Cancel').should('be.visible').then(($btn) => {
      cy.wrap($btn).click()
    })

  })

  it("rename 'elektra-test-vm' and show it's details", () => {

    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/compute/instances?searchfor=Name&search=elektra`)
    cy.get('button.dropdown-toggle').click()
    cy.contains('a','Edit').should('be.visible').then(($menu) => {
      cy.wrap($menu).click()
    })
    cy.contains('label','Name')
    let currenDate = Date.now()
    cy.get('input#server_name').type(`{selectall}elektra-test-vm (do not delete) added by e2e test ${currenDate}{enter}`)
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/test/compute/instances?searchfor=Name&search=elektra`)
    cy.contains("elektra-test-vm").click()
    cy.contains(`added by e2e test ${currenDate}`);

  })

})