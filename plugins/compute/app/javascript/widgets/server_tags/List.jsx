import React from "react"
import TagItem from "./Item"
import apiClient from "./apiClient"

const TagsList = ({ instanceId }) => {
  // init local state for TagsList
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(false)
  const [error, setError] = React.useState(null)
  const [isNew, setIsNew] = React.useState(-1)
  const [addNewTagCount, setAddNewTagCount] = React.useState(0)

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
      if (newTagValue === "") {
        // delete tag if empty
        items.splice(index, 1)
      } else {
        // write the new value into the items
        items[index] = newTagValue
      }
      setIsNew(-1)
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

  const addItem = React.useCallback(() => {
    if (isNew <= 1) {
      setItems((items) => [
        ...items,
        `please edit your new tag ${addNewTagCount}`,
      ])
      setIsNew(items.length)
      setAddNewTagCount((c) => c + 1)
    }
  }, [items, isNew])

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
              <th colSpan={2}></th>
              <th className="snug">
                <button className="btn btn-primary" onClick={() => addItem()}>
                  Add
                </button>
              </th>
            </tr>
          </thead>
          <tbody>
            {
              // render tags list
              items.map((item, index) => (
                <TagItem
                  item={item}
                  onSave={(newTagValue) => save(index, newTagValue)}
                  isNew={isNew}
                  index={index}
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
