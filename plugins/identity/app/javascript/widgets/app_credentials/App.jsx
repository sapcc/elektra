import React from "react"
import { AppShellProvider, AppShell } from "@cloudoperators/juno-ui-components"
import AppRouter from "./Approuter"

export default function App({ userId, projectId }) {
  //console.log("userId", userId)
  return (
    <>
      <AppShellProvider theme="theme-light">
        <AppShell embedded={true}>
          <AppRouter userId={userId} projectId={projectId} />
        </AppShell>
      </AppShellProvider>
    </>
  )
}
