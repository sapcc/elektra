import React from "react"

const TagItem = ({ item, onUpdate, onRemove, isNew }) => {
  // set local state got ZahItem
  const [isEditing, setIsEditing] = React.useState(isNew)
  const [newTagValue, setNewTagValue] = React.useState(item)

  const edit = React.useCallback(() => {
    setIsEditing(true)
  }, [])

  const save = React.useCallback(() => {
    onUpdate(newTagValue)
    setIsEditing(false)
  }, [newTagValue])

  const deleteTag = React.useCallback(() => {
    onRemove()
    setIsEditing(false)
  }, [setIsEditing])

  const handleKeyPress = React.useCallback(
    (e) => {
      if (e.key === "Enter") {
        save()
      }
    },
    [save]
  )

  return (
    <tr>
      <td>
        {isEditing ? (
          <input
            className="form-control"
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
      <td className="text-right">
        {isEditing ? (
          <button
            className="btn btn-sm btn-default"
            onClick={() => {
              if (isNew) onRemove()
              setIsEditing(false)
            }}
          >
            Cancel
          </button>
        ) : (
          ""
        )}{" "}
        <button
          className="btn btn-sm btn-primary"
          onClick={() => (isEditing ? save() : edit())}
        >
          {isEditing ? "Save" : "Edit"}
        </button>{" "}
        <button
          className={
            isEditing
              ? "btn btn-sm btn-warning  disabled"
              : "btn btn-sm btn-warning"
          }
          onClick={() => (isEditing ? "" : deleteTag())}
        >
          Delete
        </button>
      </td>
    </tr>
  )
}

export default TagItem
