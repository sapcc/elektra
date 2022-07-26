import React from "react"
import TagItem from "./Item"
import apiClient from "./apiClient"

const TagsList = ({ instanceId }) => {
  // init local state for TagsList
  const [items, setItems] = React.useState([])
  const [isLoading, setIsLoading] = React.useState(false)
  const [error, setError] = React.useState(null)
  const [newTagItem, setNewTagItem] = React.useState(null)

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
    (newItems) => {
      // send change request to the api
      apiClient
        .put(`servers/${instanceId}/tags`, { tags: newItems })
        .catch((error) => {
          setError(error.message)
        })
    },
    [setError]
  )

  // handle new tag items temporary in own state
  const addNewItem = React.useCallback(() => {
    setNewTagItem("this is a placeholder")
  }, [setNewTagItem, items])
  const cancelNewItem = React.useCallback(() => {
    setNewTagItem(null)
  }, [setNewTagItem])
  const saveNewItem = React.useCallback(
    (newTagValue) => {
      // push new placeholder tag value on the state
      // this will overwritten by the users new tag
      const newItems = items.slice()
      newItems.push(newTagValue)
      setNewTagItem(null)
      setItems(newItems)
      save(newItems)
    },
    [items, setItems, setNewTagItem, save]
  )
  // handle tag items
  const updateItem = React.useCallback(
    (index, newTagValue) => {
      const newItems = items.slice()
      newItems[index] = newTagValue
      setItems(newItems)
      save(newItems)
    },
    [items, setItems, save]
  )
  const removeItem = React.useCallback(
    (index) => {
      const newItems = items.slice()
      newItems.splice(index, 1)
      setItems(newItems)
      save(newItems)
    },
    [items, setItems]
  )

  return (
    <>
      <div className="modal-body">
        {
          // show error
          error && <div className="alert alert-error">{error}</div>
        }

        {/*isLoading && (
          <span>
            <span className="spinner"></span> Loading...
          </span>
        )*/}
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th className="text-right">
                <button
                  className="btn btn-sm btn-primary"
                  disabled={newTagItem}
                  onClick={() => addNewItem()}
                >
                  <i className="fa fa-plus fa-fw"></i>
                  New Tag
                </button>
              </th>
            </tr>
          </thead>
          <tbody>
            {items.length === 0 && !isLoading && !newTagItem ? (
              <tr>
                <td>No items found.</td>
              </tr>
            ) : (
              // render tags list
              items.map((item, index) => (
                <TagItem
                  item={item}
                  onUpdate={(newTagValue) => updateItem(index, newTagValue)}
                  onRemove={() => removeItem(index)}
                  key={
                    // Note: we do not use index here because of caching problems
                    //       when a tag is deleted from the list the whole order
                    //       can be is corrupted and the wrong tags are deleted
                    //       or updated if the values have the same value
                    Math.random() * Math.pow(10, 16)
                  }
                />
              ))
            )}
            {newTagItem && (
              <TagItem
                isNew
                item=""
                onUpdate={(newTagValue) => saveNewItem(newTagValue)}
                onRemove={cancelNewItem}
              />
            )}
            {isLoading && (
              <tr>
                <td>
                  <span className="spinner"></span> Loading...
                </td>
              </tr>
            )}
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
