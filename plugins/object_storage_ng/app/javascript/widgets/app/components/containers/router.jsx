import React from "react"
import { Switch, Route, useRouteMatch } from "react-router-dom"

import Containers from "./list"
import ContainerProperties from "./properties"
import DeleteContainer from "./delete"
import EmptyContainer from "./empty"
import NewContainer from "./new"
import ContainerAccessControl from "./accessControl"

const Routes = ({ objectStoreEndpoint }) => {
  let { path } = useRouteMatch()

  return (
    <React.Fragment>
      <Switch>
        <Route path={`${path}/new`} component={NewContainer} />

        <Route
          exact
          path={`${path}/:name/properties`}
          render={() => (
            <ContainerProperties objectStoreEndpoint={objectStoreEndpoint} />
          )}
        />
        <Route
          exact
          path={`${path}/:name/delete`}
          component={DeleteContainer}
        />
        <Route
          exact
          path={`${path}/:name/access-control`}
          component={ContainerAccessControl}
        />
        <Route exact path={`${path}/:name/empty`} component={EmptyContainer} />
      </Switch>
    </React.Fragment>
  )
}

export default Routes
