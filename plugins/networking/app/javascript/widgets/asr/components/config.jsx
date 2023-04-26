import React from "react"
import { JsonViewer } from "juno-ui-components/build/JsonViewer"

const Config = ({ isFetching, data, error }) => {
  if (isFetching) return <span className="spinner" />
  if (error) return <div className="alert alert-danger">{error}</div>
  if (data) {
    return <JsonViewer data={data} expanded={3} />
  }
  return null
}

export default Config
