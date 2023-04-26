/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from "react-router-dom"
import SearchRoutes from "./search/components/routes"
import React from "react"

// render all components inside a hash router
const UniversalSearchApp = (props) => (
  <HashRouter /*hashType="noslash"*/>
    <>
      <Route
        exact
        path="/"
        render={() => <Redirect to="/universal-search" />}
      />
      <SearchRoutes />
    </>
  </HashRouter>
)

export default UniversalSearchApp
