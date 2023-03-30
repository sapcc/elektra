/* eslint no-console:0 */
import React from "react"
import { BrowserRouter, Route, Redirect } from "react-router-dom"

import Tabs from "./Tabs"
// import SecretList from "./secrets/secretList"
import Secrets from "./secrets/secrets"
import SecretDetails from "./secrets/secretDetails"
import NewSecret from "./secrets/newSecret"
import Containers from "./containers/containers"
import ContainerDetails from "./containers/containerDetails"
import NewContainer from "./containers/newContainer"
import { widgetBasePath } from "lib/widget"

const tabsConfig = [
  { to: "/secrets", label: "Secrets", component: Secrets },
  { to: "/containers", label: "Containers", component: Containers },
]

const baseName = widgetBasePath("keymanagerng") 

const AppRouter = () => {
  return (
    <BrowserRouter basename={baseName}>
      <Route exact path="/" render={() => <Redirect to="/secrets" />} />
      <Route path="/:activeTab">
        <Tabs tabsConfig={tabsConfig} />
      </Route>
      <Route exact path="/secrets/newSecret" component={NewSecret} />
      <Route exact path="/secrets/:id/show" component={SecretDetails} />
      <Route exact path="/containers/newContainer" component={NewContainer} />
      <Route exact path="/containers/:id/show" component={ContainerDetails} />
    </BrowserRouter>
  )
}

export default AppRouter
