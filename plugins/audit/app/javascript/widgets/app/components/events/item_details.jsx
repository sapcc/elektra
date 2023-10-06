import React from "react"
import { JsonViewer } from "juno-ui-components"

const ItemDetails = ({ event }) => (
  <tr className="explains-previous-line">
    <td colSpan="6">
      {event.isFetchingDetails ? (
        <span className="spinner" />
      ) : (
        // <pre>{JSON.stringify(event.details, null, 2)}</pre>
        <JsonViewer data={event.details} theme="light" expanded />
      )}
    </td>
  </tr>
)

export default ItemDetails
