import React from "react"
import { render } from "@testing-library/react"
import { screen } from "@testing-library/dom"
import List from "./List"

describe("object_storage", () => {
  test("capabilities", async () => {
    await render(<List data={{}} />)
    expect(screen.getByText("Capabilities")).toBeDefined()
  })
})
