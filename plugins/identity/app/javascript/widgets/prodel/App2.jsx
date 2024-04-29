import React from "react"
import { AppShellProvider } from "juno-ui-components"
import ProjectResourceCheck from "./ProjectResourceCheck"
import styles from "./styles.scss?inline"

export default function App2() {
  const [opened, setOpened] = React.useState(false)

  const handleOnClick = React.useCallback(
    (e) => {
      e.preventDefault()
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
        <ProjectResourceCheck
          opened={opened}
          onClose={() => setOpened(false)}
        />
      </AppShellProvider>
    </>
  )
}
