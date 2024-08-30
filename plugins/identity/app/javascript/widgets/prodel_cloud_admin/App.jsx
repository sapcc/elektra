import React from "react"
import {
  JsonViewer,
  AppShellProvider,
} from "@cloudoperators/juno-ui-components"

const App = ({ jsonData }) => {
  return (
    <AppShellProvider theme="light">
      <h2>The following Resources are found:</h2>
      <JsonViewer
        toolbar
        theme="light"
        data={JSON.parse(jsonData)}
        expanded={1}
      />
    </AppShellProvider>
  )
}
export default App
