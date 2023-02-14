/* eslint-disable no-undef */
/* eslint no-console:0 */
import { BrowserRouter, Route, Redirect } from "react-router-dom"
import React from "react"
import Ports from "../containers/ports/list"
import ShowPortModal from "../containers/ports/show"
import NewPortModal from "../containers/ports/new"
import EditPortModal from "../containers/ports/edit"

// render all components inside a hash router
const PortsApp = (props) => {
  //console.log(props)
  return (
    <BrowserRouter basename={`${window.location.pathname}?r=`}>
      <div>
        {/* redirect root to shares tab */}
        {policy.isAllowed("networking:port_list") && (
          <Route exact path="/" render={() => <Redirect to="/ports" />} />
        )}
        {policy.isAllowed("networking:port_list") && (
          <Route
            path="/ports"
            render={(routeProps) => (
              <Ports {...routeProps} instancesPath={props.instancesPath} />
            )}
          />
        )}
        {policy.isAllowed("networking:port_create") && (
          <Route exact path="/ports/new" component={NewPortModal} />
        )}
        <Route exact path="/ports/:id/show" component={ShowPortModal} />
        <Route exact path="/ports/:id/edit" component={EditPortModal} />
      </div>
    </BrowserRouter>
  )
}

export default PortsApp
