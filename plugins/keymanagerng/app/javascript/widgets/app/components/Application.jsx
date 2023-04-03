/* eslint no-console:0 */
import React from "react"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import AppRouter from "./AppRouter"
import CustomCacheProvider from "./CustomCacheProvider"
import styles from "../styles.inline.css"
import StyleProvider, { AppShell } from "juno-ui-components"
import { MessagesProvider } from "messages-provider"

const queryClient = new QueryClient()

// render all components inside a hash router
const Application = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <StyleProvider theme="theme-light" stylesWrapper="shadowRoot">
        <style>{styles}</style>
        <CustomCacheProvider>
          <MessagesProvider>
            <AppShell embedded>
              <AppRouter />
            </AppShell>
          </MessagesProvider>
        </CustomCacheProvider>
      </StyleProvider>
    </QueryClientProvider>
  )
}

export default Application
