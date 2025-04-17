import React from "react"
import { AppShellProvider, AppShell } from "@cloudoperators/juno-ui-components"
import AppRouter from "./Approuter"

export default function App({ userId }) {
  console.log("userId", userId)
  return (
    <>
      <AppShellProvider theme="theme-light">
        <AppShell embedded={true}>
          <AppRouter userId={userId} />
        </AppShell>
      </AppShellProvider>
    </>
  )
}
