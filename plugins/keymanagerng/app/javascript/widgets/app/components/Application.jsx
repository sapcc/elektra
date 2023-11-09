/* eslint no-console:0 */
import React, { useState } from "react"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"
import AppRouter from "./AppRouter"
import CustomCacheProvider from "./CustomCacheProvider"
import styles from "../styles.scss?inline"
import { AppShellProvider, AppShell } from "juno-ui-components"
import { MessagesProvider } from "messages-provider"
import dayPickerStyle from "react-day-picker/dist/style.css?inline"

const queryClient = new QueryClient()

// render all components inside a hash router
const Application = () => {
  return (
    <AppShellProvider theme="theme-light">
      <QueryClientProvider client={queryClient}>
        <style>{styles} {dayPickerStyle}</style>
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
