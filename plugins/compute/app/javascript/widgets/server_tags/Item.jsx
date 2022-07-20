import React from "react"

const TagItem = ({ item, onSave }) => {
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

  const delete_tag = React.useCallback(() => {
    setIsEditing(true)
  }, [])

  return (
    <tr>
      <td>
        {isEditing ? (
          <input
            value={newTagValue}
            onChange={(e) => setNewTagValue(e.target.value)}
          />
        ) : (
          item
        )}
      </td>
      <td className="snug">
        {isEditing ? (
          <button
            className="btn btn-default"
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
          className="btn btn-primary"
          onClick={() => (isEditing ? save() : edit())}
        >
          {isEditing ? "Save" : "Edit"}
        </button>
      </td>
      <td className="snug">
        <button
          className={
            isEditing ? "btn btn-warning  disabled" : "btn btn-warning"
          }
          onClick={() => (isEditing ? "" : delete_tag())}
        >
          Delete
        </button>
      </td>
    </tr>
  )
}

export default TagItem
