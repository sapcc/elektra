import React from "react"
import TagItem from "./Item"
import apiClient from "./apiClient"

const TagsList = ({ instanceId }) => {
  // init local state for TagsList
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(false)
  const [error, setError] = React.useState(null)

  // because of empty relation array this function is called once the component is mounted
  React.useEffect(() => {
    setIsLoading(true)
    apiClient
      .get(`servers/${instanceId}/tags`)
      .then((response) => {
        //console.log(response.data)
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
      // write the new value into the items
      items[index] = newTagValue
      // send change request to the api
      apiClient
        .put(`servers/${instanceId}/tags`, { tags: items })
        // if success set items state
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
        {
          // show error
          error && <span>{error}</span>
        }
        {
          // show loading spinner
          isLoading && (
            <span>
              <span className="spinner"></span> Loading...
            </span>
          )
        }
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th className="snug"></th>
            </tr>
          </thead>
          <tbody>
            {
              // render tags list
              items.map((item, index) => (
                <TagItem
                  item={item}
                  onSave={(newTagValue) => save(index, newTagValue)}
                  key={index}
                />
              ))
            }
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
