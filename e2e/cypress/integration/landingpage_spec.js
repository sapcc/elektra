describe("Landing page", () => {
  it("loads content", () => {
    // content is loaded if children of root element exists.
    // children are built by React
    cy.request("/").should((response) => {
      expect(response.status).to.eq(200)
    })
  })
})
