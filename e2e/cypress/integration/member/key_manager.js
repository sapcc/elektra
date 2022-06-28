describe('key manager', () => {
  beforeEach(() => {
    cy.elektraLogin(
      Cypress.env('TEST_DOMAIN'),
      Cypress.env('TEST_USER'),
      Cypress.env('TEST_PASSWORD')
    )
  })

  it('Check domain, project, secrets tab names and secrets table title and column names', () => {
    cy.visit(`/${Cypress.env('TEST_DOMAIN')}/test/key-manager/secrets`)
    cy.contains('cc3test').should('have.lengthOf', 1)
    cy.contains('cc3test').should('have.attr', 'href', '/cc3test/home')
    cy.contains('test').should('have.lengthOf', 1)
    cy.contains('test').should('have.attr', 'href', '/cc3test/test/home')
    cy.contains('Key Manager').should('have.lengthOf', 1)
    cy.contains('Key Manager').should(
      'have.attr',
      'href',
      '/cc3test/test/key-manager/secrets'
    )
    cy.contains('Secrets').should('have.lengthOf', 1)
    cy.contains('Secrets').should(
      'have.attr',
      'href',
      '/cc3test/test/key-manager/secrets'
    )
    cy.contains('Available Secrets').should('have.lengthOf', 1)
    cy.contains('Name').should('have.lengthOf', 1)
    cy.contains('Type').should('have.lengthOf', 1)
    cy.contains('Content Types').should('have.lengthOf', 1)
    cy.contains('Status').should('have.lengthOf', 1)
    cy.contains('New Secret').should('have.lengthOf', 1)
    cy.contains('^The secrets resource').should('have.lengthOf', 1)
    cy.contains('1').should('have.lengthOf', 1)
    cy.contains('2').should('have.lengthOf', 1)
    cy.contains('Next').should('have.lengthOf', 1)
    cy.contains('Last').should('have.lengthOf', 1)
  })

  it('Check number of available secrets in different attribute columns', () => {
    // Check number of secrets in different columns e.g Nam, Type, Content-Type, Status in Page 1 and Page 2
    cy.contains('^c_blackbox').should('have.lengthOf', 10)
    cy.contains('public').should('have.lengthOf', 10)
    cy.contains('default').should('have.lengthOf', 10)
    cy.contains('text/plain').should('have.lengthOf', 10)
    cy.contains('Active').should('have.lengthOf', 10)
    cy.contains('2').click()
    cy.contains('First').should('have.lengthOf', 1)
    cy.contains('Prev').should('have.lengthOf', 1)
    cy.contains('^c_blackbox').should('have.lengthOf', 8)
    cy.contains('^c_blackbox').should('have.lengthOf', 8)
    cy.contains('public').should('have.lengthOf', 8)
    cy.contains('default').should('have.lengthOf', 8)
    cy.contains('text/plain').should('have.lengthOf', 8)
    cy.contains('Active').should('have.lengthOf', 8)
  })
})
