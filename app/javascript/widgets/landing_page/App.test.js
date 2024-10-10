/*
 * SPDX-FileCopyrightText: 2024 SAP SE or an SAP affiliate company and Juno contributors
 * SPDX-License-Identifier: Apache-2.0
 */

import React from "react"
import { render } from "@testing-library/react"
// support shadow dom queries
// https://reactjsexample.com/an-extension-of-dom-testing-library-to-provide-hooks-into-the-shadow-dom/
import { screen } from "shadow-dom-testing-library"
import App from "./App"

jest.mock("./lib/pages-loader", () => ({
  __esModule: true,
  getPages: () => {
    const fs = require("fs")
    const path = require("path")
    return fs.readdirSync(path.resolve("./src/pages")).map((file) => ({
      name: file.replace(/\.js/, ""),
      component: require(path.resolve("./src/pages", file)).default,
    }))
  },
}))

test("renders Converged Cloud heading", async () => {
  const { debug } = render(<App />)
  // debug()

  const text = await screen.getByShadowAltText(/Converged Cloud/i)
  expect(text).toBeInTheDocument()
})
