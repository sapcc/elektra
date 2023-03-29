/* eslint no-console:0 */
import React from "react"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import AppRouter from "./AppRouter"
import styles from "../styles.inline.css"

import StyleProvider, { AppShell } from "juno-ui-components"
import { CacheProvider } from "@emotion/react"
import createCache from "@emotion/cache"

const myCache = createCache({
  key: "my-prefix-key",
})

const queryClient = new QueryClient()

// render all components inside a hash router
const Application = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <StyleProvider theme="theme-light" stylesWrapper="shadowRoot">
        <style>{styles}</style>
        <CacheProvider value={myCache}>
          <AppShell embedded>
            <AppRouter />
          </AppShell>
        </CacheProvider>
      </StyleProvider>
    </QueryClientProvider>
  )
}

export default Application
