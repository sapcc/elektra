import { Route } from "react-router-dom"
import React from "react"
import Home from "../containers/home"
import Projects from "../containers/project_role_assignments/projects"
import LiveSearchModal from "../containers/live_search"
import ShowItemModal from "../containers/show"

const Routes = () => (
  <React.Fragment>
    <Route path="/universal-search" component={Home} />
    <Route exact path="/universal-search/:id/show" component={ShowItemModal} />
    <Route path="/universal-search/live" component={LiveSearchModal} />
    <Route path="/project-role-assignments" component={Projects} />
    <Route
      path="/project-role-assignments/:id/show"
      component={ShowItemModal}
    />
  </React.Fragment>
)

export default Routes
