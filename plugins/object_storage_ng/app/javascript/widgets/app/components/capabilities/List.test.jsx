import React from "react"
import renderer from "react-test-renderer"
import List from "./List"

describe("router", () => {
  test("routes", () => {
    const component = renderer.create(<List data={{}} />)
    let tree = component.toJSON()
    expect(tree).toMatchSnapshot()
  })
})
