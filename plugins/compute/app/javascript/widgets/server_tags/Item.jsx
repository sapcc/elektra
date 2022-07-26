import React from "react"

const TagItem = ({ item, onUpdate, onRemove, isNew }) => {
  // set local state got ZahItem
  const [isEditing, setIsEditing] = React.useState(isNew)
  const [confirmDeleting, setConfirmDeleting] = React.useState(false)
  const [newTagValue, setNewTagValue] = React.useState(item)
  const [isToSmall, setIsToSmall] = React.useState(false)
  const inputElement = React.useRef()

  React.useEffect(() => {
    // this is called after render
    // console.log("useEfect", isEditing, inputElement)
    if (isEditing && inputElement.current) {
      inputElement.current.focus()
    }

    handleEmptyTagValue(item)

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
    setConfirmDeleting(true)
    setIsEditing(false)
    //if (timer) clearTimeout(timer)
    onRemove()
  }, [setIsEditing, setConfirmDeleting])

  /*
  let timer
  const getDeleteConfirmation = React.useCallback(() => {
    if (timer) clearTimeout(timer)
    setConfirmDeleting(true)
    timer = setTimeout(() => {
      //console.log("#", confirmDeleting)
      setConfirmDeleting(false)
    }, 15000)
  }, [timer])
  */

  const handleKeyPress = React.useCallback(
    (key) => {
      if (key === "Enter") {
        save()
      }
    },
    [save]
  )

  const handleEmptyTagValue = React.useCallback((value) => {
    if (value.length === 0) {
      setIsToSmall(true)
    } else {
      setIsToSmall(false)
    }
    setNewTagValue(value)
  })

  return (
    <tr>
      <td>
        <div className="h4">
          {isEditing ? (
            <input
              className="form-control"
              type="text"
              style={{ width: "100%" }}
              value={newTagValue}
              onChange={(e) => handleEmptyTagValue(e.target.value)}
              onKeyPress={(e) => handleKeyPress(e.key)}
              placeholder="add your tag here"
              ref={inputElement}
            />
          ) : (
            /* : confirmDeleting ? (
          <span>
            Do you realy want to delete this tag?&nbsp;
            <button
              className="btn btn-sm btn-danger"
              onClick={() => deleteTag()}
            >
              <i className="fa fa-check"></i>
            </button>
            <button
              className="btn btn-sm btn-success"
              onClick={() => setConfirmDeleting(false)}
            >
              <i className="fa fa-times"></i>
            </button>
          </span>
        )*/
            <span>
              <li className="fa fa-tag"></li>{" "}
              <span className="label label-default">{item}</span>
            </span>
          )}
        </div>
      </td>
      <td className="text-right">
        <div className="btn-group">
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
            className={
              !isEditing
                ? "btn btn-default btn-sm"
                : isToSmall
                ? "btn btn-success btn-sm disabled"
                : "btn btn-success btn-sm"
            }
            onClick={() => (isEditing ? save() : edit())}
          >
            <i className={isEditing ? "fa fa-floppy-o" : "fa fa-pencil"}></i>
          </button>{" "}
          <button
            className={
              isEditing || confirmDeleting
                ? "btn btn-sm btn-warning  disabled"
                : "btn btn-sm btn-warning"
            }
            //onClick={() => (isEditing ? "" : getDeleteConfirmation())}
            onClick={() => (isEditing ? "" : deleteTag())}
          >
            <i className="fa fa-trash"></i>
          </button>
        </div>
      </td>
    </tr>
  )
}

export default TagItem
