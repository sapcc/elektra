import React from "react"
import PropTypes from "prop-types"
import { BrowserRouter, Route, Redirect, Switch } from "react-router-dom"

import ContainerProperties from "./components/containers/properties"
import DeleteContainer from "./components/containers/delete"
import EmptyContainer from "./components/containers/empty"
import NewContainer from "./components/containers/new"
import ContainerAccessControl from "./components/containers/accessControl"
import Containers from "./components/containers/list"
import Objects from "./components/objects/list"

const Router = ({ baseName, objectStoreEndpoint }) => (
  <BrowserRouter basename={baseName}>
    {/* redirect root to shares tab */}
    <Route exact path="/">
      <Redirect to="/containers" />
    </Route>

    <Switch>
      <Route path="/containers/:name/objects/:objectPath?">
        <Objects objectStoreEndpoint={objectStoreEndpoint} />
      </Route>

      <Route path="/containers">
        <Containers />
        <Route exact path="/containers/new" component={NewContainer} />

        <Route
          exact
          path={`/containers/:name/properties`}
          render={() => (
            <ContainerProperties objectStoreEndpoint={objectStoreEndpoint} />
          )}
        />

        <Route
          exact
          path={`/containers/:name/delete`}
          component={DeleteContainer}
        />
        <Route
          exact
          path={`/containers/:name/access-control`}
          component={ContainerAccessControl}
        />
        <Route
          exact
          path={`/containers/:name/empty`}
          component={EmptyContainer}
        />
      </Route>
    </Switch>
  </BrowserRouter>
)

Router.propTypes = {
  baseName: PropTypes.string.isRequired,
  objectStoreEndpoint: PropTypes.string.isRequired,
}

export default Router
