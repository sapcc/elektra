import React from "react"

const TagItem = ({ item, onSave, isNew, index }) => {
  // set local state got ZahItem
  const [isEditing, setIsEditing] = React.useState(false)
  const [newTagValue, setNewTagValue] = React.useState(item)

  const edit = React.useCallback(() => {
    setIsEditing(true)
  }, [])

  const save = React.useCallback(() => {
    onSave(newTagValue)
    setIsEditing(false)
  }, [newTagValue])

  const deleteTag = React.useCallback(() => {
    onSave("")
    setIsEditing(false)
  }, [newTagValue])

  const editing = (isEditing, isNew, index) => {
    //console.log(isEditing,isNew,index)
    if (isNew === index) {
      return true
    }
    if (isEditing) {
      return true
    }
    return false
  }

  const handleKeyPress = (e) => {
    if (e.key === "Enter") {
      save()
    }
  }

  return (
    <tr>
      <td>
        {editing(isEditing, isNew, index) ? (
          <input
            type="text"
            style={{ width: "100%" }}
            value={newTagValue}
            onChange={(e) => setNewTagValue(e.target.value)}
            onKeyPress={(e) => handleKeyPress(e)}
          />
        ) : (
          item
        )}
      </td>
      <td className="snug">
        {editing(isEditing, -1, index) ? (
          <button
            className="btn btn-sm btn-default"
            onClick={() => setIsEditing(false)}
          >
            Cancel
          </button>
        ) : (
          ""
        )}
      </td>
      <td className="snug">
        <button
          className="btn btn-sm btn-primary"
          onClick={() => (editing(isEditing, isNew, index) ? save() : edit())}
        >
          {editing(isEditing, isNew, index) ? "Save" : "Edit"}
        </button>
      </td>
      <td className="snug">
        <button
          className={
            editing(isEditing, isNew, index)
              ? "btn btn-sm btn-warning  disabled"
              : "btn btn-sm btn-warning"
          }
          onClick={() => (editing(isEditing, isNew, index) ? "" : deleteTag())}
        >
          Delete
        </button>
      </td>
    </tr>
  )
}

export default TagItem
