/* eslint no-console:0 */
import React from "react"
import { BrowserRouter, Route, Redirect, Switch } from "react-router-dom"

import StateProvider from "./stateProvider"
import { reducer, initialState } from "./reducers"

// import ContainerProperties from "./components/containers/properties"
// import DeleteContainer from "./components/containers/delete"
// import EmptyContainer from "./components/containers/empty"
// import NewContainer from "./components/containers/new"
// import ContainerAccessControl from "./components/containers/accessControl"
// import Containers from "./components/containers/list"
// import Objects from "./components/objects/list"
// import NewObject from "./components/objects/new"

import Containers from "./components/containers/list"
import Objects from "./components/objects/list"

// import ContainersRouter from "./components/containers/router"
// import ObjectsRouter from "./components/objects/router"

// render all components inside a hash router
const App = (props) => {
  // <StateProvider reducer={reducer} initialState={initialState}>
  //   <BrowserRouter basename={`${window.location.pathname}?r=`}>
  //     {/* redirect root to shares tab */}

  //     <Route exact path="/">
  //       <Redirect to="/containers" />
  //     </Route>

  //     <Switch>
  //       <Route exact path="/containers/:name/objects/:path?">
  //         <Objects />
  //         <Switch>
  //           <Route
  //             exact
  //             path="/containers/:name/objects/:path?/new"
  //             component={NewObject}
  //           />
  //         </Switch>
  //       </Route>
  //       <Route path="/containers">
  //         <Containers />
  //         <Switch>
  //           <Route exact path="/containers/new" component={NewContainer} />

  //           <Route
  //             exact
  //             path="/containers/:name/properties"
  //             component={ContainerProperties}
  //           />
  //           <Route
  //             exact
  //             path="/containers/:name/delete"
  //             component={DeleteContainer}
  //           />
  //           <Route
  //             exact
  //             path="/containers/:name/access-control"
  //             component={ContainerAccessControl}
  //           />
  //           <Route
  //             exact
  //             path="/containers/:name/empty"
  //             component={EmptyContainer}
  //           />
  //         </Switch>
  //       </Route>
  //     </Switch>
  //   </BrowserRouter>
  // </StateProvider>
  return (
    <StateProvider reducer={reducer} initialState={initialState}>
      <BrowserRouter basename={`${window.location.pathname}?r=`}>
        {/* redirect root to shares tab */}

        <Route exact path="/">
          <Redirect to="/containers" />
        </Route>

        <Switch>
          <Route
            path="/containers/:name/objects/:objectPath?"
            component={Objects}
          />
          <Route
            path="/containers"
            render={() => (
              <Containers objectStoreEndpoint={props.objectStoreEndpoint} />
            )}
          />
        </Switch>
      </BrowserRouter>
    </StateProvider>
  )
}

export default App
