import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import Router from "./components/Router"
import FloatingFlashMessages from "./components/shared/FloatingFlashMessages"
import Log from "./components/shared/logger"
import { QueryClient, QueryClientProvider } from "react-query"
import React from "react"

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
    <App />
  </StateProvider>
)

export default LbassApp
