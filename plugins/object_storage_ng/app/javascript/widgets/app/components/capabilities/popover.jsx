import React from "react"
import Capabilities from "./list"
import { useGlobalState } from "../../stateProvider"
import useActions from "../../hooks/useActions"
import { createUseStyles } from "react-jss"
import { Popover, OverlayTrigger } from "react-bootstrap"

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
    <OverlayTrigger
      trigger="click"
      placement="left"
      overlay={
        <Popover
          className={classes.popoverCapabilities}
          id="popover-capabilities"
          title="Cluster limits and capabilities"
        >
          {capabilities.isFetching ? (
            <span>
              <span className="spinner" />
              Loading...
            </span>
          ) : (
            <Capabilities data={capabilities.data} />
          )}
        </Popover>
      }
    >
      <a href="#">
        <i className="fa fa-info-circle" />
      </a>
    </OverlayTrigger>
  )
}
export default CapabilitiesPopover
