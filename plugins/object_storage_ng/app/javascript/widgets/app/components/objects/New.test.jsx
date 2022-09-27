import React from "react"
import renderer from "react-test-renderer"
import New from "./New"

describe("router", () => {
  test("routes", () => {
    const component = renderer.create(<New />)
    let tree = component.toJSON()

    console.log("===", component)
    expect(tree).toMatchSnapshot()

    // manually trigger the callback
    renderer.act(() => {
      tree.props.onMouseEnter()
    })
    // re-rendering
    tree = component.toJSON()
    expect(tree).toMatchSnapshot()

    // manually trigger the callback
    renderer.act(() => {
      tree.props.onMouseLeave()
    })
    // re-rendering
    tree = component.toJSON()
    expect(tree).toMatchSnapshot()
  })
})
