import React from "react"
import { createAjaxHelper } from "lib/ajax_helper"
import TagItem from "./Item"

const ajaxClient = createAjaxHelper()

const TagsList = ({ instanceId }) => {
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(false)
  const [error, setError] = React.useState(null)

  React.useEffect(() => {
    setIsLoading(true)
    ajaxClient
      .get(`os-api/compute/servers/${instanceId}/tags`, {
        params: { headers: { "X-OpenStack-Nova-API-Version": "2.26" } },
      })
      .then((response) => {
        console.log(response.data)
        setItems(response.data.tags)
      })
      .catch((error) => {
        setError(error.message)
      })
      .finally(() => {
        setIsLoading(false)
      })
  }, [])

  const save = React.useCallback(
    (index, newTagValue) => {
      items[index] = newTagValue
      ajaxClient
        .put(
          `os-api/compute/servers/${instanceId}/tags`,
          { body: JSON.stringify({ tags: items }) },
          {
            params: {
              headers: {
                "X-OpenStack-Nova-API-Version": "2.26",
                "Content-Type": "application/json",
              },
            },
          }
        )
        .then((response) => setItems(response.data.tags))
        .catch((error) => {
          setError(error.message)
        })
    },
    [items]
  )

  return (
    <>
      <div className="modal-body">
        {error && <span>{error}</span>}
        {isLoading && (
          <span>
            <span className="spinner"></span> Loading...
          </span>
        )}
        <table className="table">
          {" "}
          <thead>
            <tr>
              <th>Name</th>
              <th className="snug"></th>
            </tr>
          </thead>
          <tbody>
            {items.map((item, index) => (
              <TagItem
                item={item}
                onSave={(newTagValue) => save(index, newTagValue)}
                key={index}
              />
            ))}
          </tbody>
        </table>
      </div>
      <div className="buttons modal-footer">
        <button
          aria-label="Close"
          className="btn btn-default"
          data-dismiss="modal"
          type="button"
        >
          Close
        </button>
      </div>
    </>
  )
}

export default TagsList
