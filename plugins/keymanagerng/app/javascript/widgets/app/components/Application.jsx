/* eslint no-console:0 */
import React from "react"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import { HashRouter, Route, Redirect } from "react-router-dom"

import Tabs from "./Tabs"
// import SecretList from "./secrets/secretList"
import Secrets from "./secrets/secrets"
import SecretDetails from "./secrets/secretDetails"
import NewSecret from "./secrets/newSecret"
import Containers from "./containers/containers"
import ContainerDetails from "./containers/containerDetails"
import NewContainer from "./containers/newContainer"
import styles from "../styles.inline.css"

import StyleProvider, { AppShell } from "juno-ui-components"
import { BrowserRouter } from "react-router-dom/cjs/react-router-dom.min"
import { widgetBasePath } from "lib/widget"
import { CacheProvider } from "@emotion/react"
import createCache from "@emotion/cache"

const myCache = createCache({
  key: "my-prefix-key",
})

const tabsConfig = [
  { to: "/secrets", label: "Secrets", component: Secrets },
  { to: "/containers", label: "Containers", component: Containers },
]

const baseName = widgetBasePath("keymanagerng")

const queryClient = new QueryClient()

// render all components inside a hash router
const Application = () => {
  return (
    <QueryClientProvider client={queryClient}>
        <StyleProvider theme="theme-light" stylesWrapper="shadowRoot">
          <style>{styles}</style>
          <CacheProvider value={myCache}>
            <AppShell embedded>
              <BrowserRouter basename={baseName}>
                <Route path="/:activeTab">
                  <Tabs tabsConfig={tabsConfig} />
                </Route>
                <Route exact path="/secrets/newSecret" component={NewSecret} />
                <Route
                  exact
                  path="/secrets/:id/show"
                  component={SecretDetails}
                />
                <Route
                  exact
                  path="/containers/newContainer"
                  component={NewContainer}
                />
                <Route
                  exact
                  path="/containers/:id/show"
                  component={ContainerDetails}
                />
              </BrowserRouter>
            </AppShell>
          </CacheProvider>
        </StyleProvider>
    </QueryClientProvider>
  )
}

export default Application
