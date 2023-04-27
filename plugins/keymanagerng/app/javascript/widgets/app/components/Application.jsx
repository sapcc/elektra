/* eslint no-console:0 */
import React, { useState } from "react"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import AppRouter from "./AppRouter"
import CustomCacheProvider from "./CustomCacheProvider"
import styles from "../styles.inline.css"
import { AppShellProvider, AppShell } from "juno-ui-components"
import { MessagesProvider } from "messages-provider"

const queryClient = new QueryClient()

// render all components inside a hash router
const Application = () => {
  return (
    <AppShellProvider theme="theme-light">
      <QueryClientProvider client={queryClient}>
        <style>{styles}</style>
        <CustomCacheProvider>
          <MessagesProvider>
            <AppShell embedded>
              <AppRouter />
            </AppShell>
          </MessagesProvider>
        </CustomCacheProvider>
      </QueryClientProvider>
    </AppShellProvider>
  )
}

export default Application
