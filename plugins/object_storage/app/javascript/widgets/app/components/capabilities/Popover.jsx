import React from "react"
import Capabilities from "./List"
import { useGlobalState } from "../../StateProvider"
import useActions from "../../hooks/useActions"
import { createUseStyles } from "react-jss"
import { Popover } from "lib/components/Overlay"
import { renderToString } from "react-dom/server"

const useStyles = createUseStyles({
  popoverCapabilities: {
    width: 500,
    maxWidth: "none !important",
  },
})

const CapabilitiesPopover = () => {
  const classes = useStyles()
  const capabilities = useGlobalState("capabilities")
  const { loadCapabilitiesOnce } = useActions()

  React.useEffect(() => {
    loadCapabilitiesOnce()
  }, [loadCapabilitiesOnce])

  return (
    <Popover
      trigger="click"
      placement="left"
      html
      title="Cluster limits and capabilities"
      content={renderToString(
        <>
          {capabilities.isFetching ? (
            <span>
              <span className="spinner" />
              Loading...
            </span>
          ) : (
            <Capabilities data={capabilities.data} />
          )}
        </>
      )}
    >
      <a href="#">
        <i className="fa fa-info-circle" />
      </a>
    </Popover>
  )
}
export default CapabilitiesPopover
