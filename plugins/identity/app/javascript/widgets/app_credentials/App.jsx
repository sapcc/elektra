import React from "react"
import { AppShellProvider, AppShell } from "@cloudoperators/juno-ui-components"
import List from "./List"

export default function App({ userId }) {
  console.log("userId", userId)
  return (
    <>
      <AppShellProvider theme="theme-light">
        <AppShell embedded={true}>
          <List userId={userId} />
        </AppShell>
      </AppShellProvider>
    </>
  )
}
