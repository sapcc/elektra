describe("Resource Management - Project Level", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("Start page is reachable, you need the resource_admin role and ypu can access dns, network, storage, and availability_zones tab", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project`)
    cy.contains('div','Members per Server Group')
    cy.contains('you need the resource_admin role')

    cy.get('a[href*="#/dns"]').click()
    cy.contains('div','Recordsets per Zone')

    cy.get('a[href*="#/network"]').click()
    cy.contains('div','Security Group Rules')

    cy.get('a[href*="#/storage"]').click()
    cy.contains('div','Shared Filesystem Storage (Premium SSD)')
    cy.contains('div','Shared Filesystem Storage (Hypervisor Storage)')

    cy.get('a[href*="#/availability_zones"]').click()
    cy.contains('div', 'Block Storage (Premium SSD)')
    cy.contains('div', 'Block Storage (Standard HDD)')
  })

  it("DNS page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/dns`)
    cy.contains('div','Recordsets per Zone')
    cy.contains('you need the resource_admin role')
    
  })

  it("Network page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/network`)
    cy.contains('div','Security Group Rules')
    cy.contains('you need the resource_admin role')
    
  })

  it("Storage page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/storage`)
    cy.contains('div','Shared Filesystem Storage (Premium SSD)')
    cy.contains('div','Shared Filesystem Storage (Hypervisor Storage)')
    cy.contains('you need the resource_admin role')
    
  })

  it("Availability zones page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/availability_zones`)
    cy.contains('div', 'Block Storage (Premium SSD)')
    cy.contains('div', 'Block Storage (Standard HDD)')
    cy.contains('you need the resource_admin role')
  })

})