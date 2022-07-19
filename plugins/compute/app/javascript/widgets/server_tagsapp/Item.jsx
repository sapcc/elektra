import React from "react"

const TagItem = ({ item, onSave }) => {
  const [isEditing, setIsEditing] = React.useState(false)
  const [newTagValue, setNewTagValue] = React.useState(item)

  const edit = React.useCallback(() => {
    setIsEditing(true)
  }, [])
  const save = React.useCallback(() => {
    onSave(newTagValue)
    setIsEditing(false)
  }, [newTagValue])

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
      <td>
        <button
          className="btn btn-primary"
          onClick={() => (isEditing ? save() : edit())}
        >
          {isEditing ? "Save" : "Edit"}
        </button>
      </td>
    </tr>
  )
}

export default TagItem
