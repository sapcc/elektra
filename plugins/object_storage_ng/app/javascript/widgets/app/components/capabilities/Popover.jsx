import React from "react"
import Capabilities from "./List"
import { useGlobalState } from "../../StateProvider"
import { Popover } from "lib/components/Overlay"
import { renderToString } from "react-dom/server"
import { useCapabilitiesLoadOnce } from "../../data/hooks/capabilities"

const CapabilitiesPopover = () => {
  const capabilities = useGlobalState("capabilities")
  const loadCapabilitiesOnce = useCapabilitiesLoadOnce()

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
