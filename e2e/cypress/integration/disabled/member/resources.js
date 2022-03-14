describe("resource management - project level", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("start page is reachable, you need the resource_admin role and ypu can access dns, network, storage, and availability_zones tab",{ defaultCommandTimeout: 30000 }, () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project`)
    cy.contains('[data-test=page-title]','Manage Project Resources')

    cy.contains('div','Members per Server Group')
    cy.contains('you need the resource_admin role')

    cy.get('a[href*="#/dns"]').click()
    cy.contains('Recordsets per Zone')

    cy.get('a[href*="#/network"]').click()
    cy.contains('Security Group Rules')

    cy.get('a[href*="#/storage"]').click()
    cy.contains('Shared Filesystem Storage (Premium SSD)')
    cy.contains('Shared Filesystem Storage (Hypervisor Storage)')

    cy.get('a[href*="#/availability_zones"]').click()
    cy.contains('Block Storage (Premium SSD)')
    cy.contains('Block Storage (Standard HDD)')
  })

  it("dns page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/dns`)
    cy.contains('Recordsets per Zone')
    cy.contains('you need the resource_admin role')
  })

  it("network page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/network`)
    cy.contains('Security Group Rules')
    cy.contains('you need the resource_admin role')
  })

  it("storage page is directly reachable and you need the resource_admin role", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/storage`)
    cy.contains('Shared Filesystem Storage (Premium SSD)')
    cy.contains('Shared Filesystem Storage (Hypervisor Storage)')
    cy.contains('you need the resource_admin role')
  })

  it("availability zones page is directly reachable and you need the resource_admin role", { defaultCommandTimeout: 30000 }, () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/member/resources/project#/availability_zones`)
    cy.contains('Block Storage (Premium SSD)')
    cy.contains('Block Storage (Standard HDD)')
    cy.contains('you need the resource_admin role')
  })

})