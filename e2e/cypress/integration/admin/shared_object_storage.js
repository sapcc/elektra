describe("shared object storage", () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env("TEST_DOMAIN"),
      Cypress.env("TEST_USER"),
      Cypress.env("TEST_PASSWORD")
    )
  })

  it("open object storage and check create container button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/object-storage/`)
    cy.contains('[data-test=page-title]','Object Storage')
    cy.contains('a','Create container').click()
    cy.contains('Inside a project, objects are stored in containers. Containers are where you define access permissions and quotas.')
    cy.contains('button','Cancel').click()
  })

  it("open object storage and check access control and check ACLs button", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/object-storage/containers?overlay=elektra-test%2Fshow_access_control`)
    cy.contains('Read ACLs')
    cy.contains('textarea','.rlistings')
    cy.contains('a','Check ACLs').click()
    cy.contains('valid token required: false')
  })

  it("open object storage and check elektra-test container", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/object-storage/containers/elektra-test`)
    cy.contains('Object count')
    cy.contains('Metadata')
  })

  it("open object storage and elektra-test container and check actions", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/object-storage/`)
    cy.contains('[data-test=page-title]','Object Storage')
    cy.contains('a','elektra-test').click()
    cy.contains('a','Create folder').click()
    cy.contains('Folder name')
    cy.contains('button','Cancel').click()
    cy.contains('a','Upload file').click()
    cy.contains('This dialog only accepts files smaller than 1 MiB. To upload larger files, please use a different client.')
    cy.contains('button','Cancel').click()
  })

  it("open elektra-test container directly and check item", () => {
    cy.visit(`/${Cypress.env("TEST_DOMAIN")}/admin/object-storage/containers/elektra-test/list`)
    cy.contains('[data-test=page-title]','Object Storage')
    cy.contains('a','amiga.jpg')
    cy.get('div.btn-group').click()
    cy.contains('a','Properties').click()
    cy.contains('File: amiga.jpg')
    cy.contains('button','Cancel').click()

    cy.get('div.btn-group').click()
    cy.contains('a','Copy').click()
    cy.contains('Copy object: amiga.jpg')
    cy.contains('button','Cancel').click()

    cy.get('div.btn-group').click()
    cy.contains('a','Move/Rename').click()
    cy.contains('Move and/or rename object: amiga.jpg')
    cy.contains('button','Cancel').click()
  })

})