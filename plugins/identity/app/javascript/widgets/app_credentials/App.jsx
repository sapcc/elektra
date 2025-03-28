import React from "react"
import { AppShellProvider, AppShell } from "@cloudoperators/juno-ui-components"

export default function App() {

  return (
    <>
      <AppShellProvider theme="theme-light">
        <AppShell embedded={true}>
          hallo welt 😀
        </AppShell>
      </AppShellProvider>
    </>
  )
}
