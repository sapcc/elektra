import React from "react"

const TagItem = ({ item, onUpdate, onRemove, isNew }) => {
  // set local state got ZahItem
  const [isEditing, setIsEditing] = React.useState(isNew)
  const [newTagValue, setNewTagValue] = React.useState(item)
  const inputElement = React.useRef()

  React.useEffect(() => {
    // this is called after render
    // console.log("useEfect", isEditing, inputElement)
    if (isEditing && inputElement.current) {
      inputElement.current.focus()
    }
    //return () => {
    // this is called when the component is unmounted
    // can be used for cleanup
    //  console.log("cleanup")
    //}
  }, [isEditing])

  const edit = React.useCallback(() => {
    setIsEditing(true)
  }, [setIsEditing])

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
            ref={inputElement}
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
            <i className="fa fa-times"></i>
          </button>
        ) : (
          ""
        )}{" "}
        <button
          className="btn btn-default btn-sm"
          onClick={() => (isEditing ? save() : edit())}
        >
          <i className={isEditing ? "fa fa-floppy-o" : "fa fa-pencil"}></i>
        </button>{" "}
        <button
          className={
            isEditing
              ? "btn btn-sm btn-default  disabled"
              : "btn btn-sm btn-warning"
          }
          onClick={() => (isEditing ? "" : deleteTag())}
        >
          <i className="fa fa-trash"></i>
        </button>
      </td>
    </tr>
  )
}

export default TagItem
