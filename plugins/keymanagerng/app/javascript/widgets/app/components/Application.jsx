/* eslint no-console:0 */
import React from "react"
import { HashRouter, Route, Redirect } from "react-router-dom"

import Tabs from "./Tabs"
// import SecretList from "./secrets/secretList"
import Secrets from "./secrets/secrets"
import SecretDetails from "./secrets/secretDetails"
import NewSecret from "./secrets/newSecret"
import Containers from "./containers/containerList"
import ContainerDetailsModal from "./containers/containerDetailsForm"
import NewContainer from "./containers/newContainer"
import StateProvider from "./StateProvider"
import styles from "../styles.inline.css"

import StyleProvider, { AppShell } from "juno-ui-components"
import { BrowserRouter } from "react-router-dom/cjs/react-router-dom.min"
import { widgetBasePath } from "lib/widget"

const tabsConfig = [
  { to: "/secrets", label: "Secrets", component: Secrets },
  { to: "/containers", label: "Containers", component: Containers },
]

const baseName = widgetBasePath("keymanagerng")

// render all components inside a hash router
const Application = () => {
  return (
    <StateProvider>
      <StyleProvider theme="theme-light" stylesWrapper="shadowRoot">
        <style>{styles}</style>
        {/* redirect root to shares tab */}
        <AppShell embedded>
          {/* <BrowserRouter basename={`${window.location.pathname}?r=`}> */}
          <BrowserRouter basename={baseName}>
            <Route path="/:activeTab">
              <Tabs tabsConfig={tabsConfig} />
            </Route>
            <Route exact path="/secrets/newSecret" component={NewSecret} />
            <Route exact path="/secrets/:id/show" component={SecretDetails} />
            <Route
              exact
              path="/containers/newContainer"
              component={NewContainer}
            />
            <Route
              exact
              path="/containers/:id/show"
              component={ContainerDetailsModal}
            />
          </BrowserRouter>
        </AppShell>
      </StyleProvider>
    </StateProvider>
  )
}

export default Application
