import React from "react"
import { AppShellProvider, AppShell } from "@cloudoperators/juno-ui-components"
import ProjectResourceCheck from "./ProjectResourceCheck"
import styles from "./styles.scss?inline"

export default function App() {
  const [opened, setOpened] = React.useState(false)

  // This function is called when the link `Check` is clicked
  const handleOnClick = React.useCallback(
    (e) => {
      e.preventDefault()
      // Toggle the state of `opened`
      setOpened(!opened)
    },
    [opened]
  )

  return (
    <>
      <a href="#" onClick={handleOnClick}>
        Check
      </a>
      <AppShellProvider theme="theme-light">
        <style>{styles}</style>
        <AppShell embedded={true}>
          <ProjectResourceCheck
            opened={opened}
            onClose={() => setOpened(false)}
          />
        </AppShell>
      </AppShellProvider>
    </>
  )
}
