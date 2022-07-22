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
    if (!instanceId) {
      return
    }
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
  }, [instanceId])

  const save = React.useCallback((newItems) => {
    console.log("itemListIsMounted")
    // send change request to the api
    apiClient
      .put(`servers/${instanceId}/tags`, { tags: newItems })
      .catch((error) => {
        setError(error.message)
      })
    return () => {
      console.log("ItemListUnMounted")
    }
  }, [])

  // add temporary new item
  const addNewItem = React.useCallback(() => {
    setNewTagItem(`please edit your new tag ${items.length + 1}`)
  }, [setNewTagItem, items])
  // remove temporary new item
  const cancelNewItem = React.useCallback(() => {
    setNewTagItem(null)
  }, [setNewTagItem])
  // save new item to item state
  const saveNewItem = React.useCallback(
    (newTagValue) => {
      const newItems = items.slice()
      newItems.push(newTagValue)
      setNewTagItem(null)
      setItems(newItems)
      save(newItems)
    },
    [items, setItems, setNewTagItem, save]
  )

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
      console.log(index)
      const newItems = items.slice()
      newItems.splice(index, 1)
      setItems(newItems)
    },
    [items, setItems]
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
              <th className="text-right">
                <button
                  className="btn btn-primary"
                  disabled={newTagItem}
                  onClick={() => addNewItem()}
                >
                  New Tag
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
                  onUpdate={(newTagValue) => updateItem(index, newTagValue)}
                  onRemove={() => removeItem(index)}
                  key={Math.random() * Math.pow(10, 16)}
                />
              ))
            }
            {newTagItem && (
              <TagItem
                isNew
                item={newTagItem}
                onUpdate={(newTagValue) => saveNewItem(newTagValue)}
                onRemove={cancelNewItem}
              />
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
