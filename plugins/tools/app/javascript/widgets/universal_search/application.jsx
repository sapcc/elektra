/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from "react-router-dom"
import { withRouter } from "react-router"

import SearchRoutes from "./search/components/routes"

// render all components inside a hash router
export default (props) => (
  <HashRouter /*hashType="noslash"*/>
    <React.Fragment>
      <Route
        exact
        path="/"
        render={() => <Redirect to="/universal-search" />}
      />
      <SearchRoutes />
    </React.Fragment>
  </HashRouter>
)
