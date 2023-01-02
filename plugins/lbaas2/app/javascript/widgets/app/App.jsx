import React from "react"

import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import Router from "./components/Router"
import FloatingFlashMessages from "./components/shared/FloatingFlashMessages"
import Log from "./components/shared/logger"
import { QueryClient, QueryClientProvider } from "react-query"

import StyleProvider, { AppShell } from "juno-ui-components"
import styles from "./styles.css"

const App = () => {
  // Create a client
  const queryClient = new QueryClient()

  Log.debug("RENDER App")
  return (
    <QueryClientProvider client={queryClient}>
      <FloatingFlashMessages />
      <Router />
    </QueryClientProvider>
  )
}
const LbassApp = () => (
  <StateProvider reducers={reducers}>
    <StyleProvider theme="theme-light" stylesWrapper="inline">
      <style>{styles.toString()}</style>
      <AppShell embedded>
        <App />
      </AppShell>
    </StyleProvider>
  </StateProvider>
)

export default LbassApp
