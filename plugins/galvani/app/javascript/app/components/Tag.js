import React, { useState } from "react"
import SmartLink from "./shared/SmartLink"
import { Button, Collapse } from "react-bootstrap"
import { removeTag, fetchTags } from "../actions/tags"
import { addNotice, addError } from "lib/flashes"
import { useDispatch } from "./StateProvider"
import { errorMessage } from "../../lib/hooks/useTag"

const Tag = ({ tag }) => {
  const [showConfirm, setShowConfirm] = useState(false)
  const [deleting, setDeleting] = useState(false)
  const dispatch = useDispatch()
  const canDelete = true

  const onDeleteClick = () => {
    setShowConfirm(true)
  }

  const onConfirmDeleteClick = () => {
    setDeleting(true)

    // TODO: return tag value or service name and action as notice
    console.log("removing tag: ", tag)

    return removeTag(tag.tag)
      .then((response) => {
        if (response) {
          addNotice(
            <>
              Access profile <b>{response.tag}</b> has been removed.
            </>
          )
        }
        loadTags()
      })
      .catch((error) => {
        setDeleting(false)
        addError(`Could not remove access profile, ${errorMessage(error)}`)
      })
  }

  const loadTags = () => {
    fetchTags()
      .then((data) => {
        dispatch({
          type: "RECEIVE_TAGS",
          tags: data.tags,
        })
      })
      .catch((error) => {
        dispatch({
          type: "REQUEST_TAGS_FAILURE",
          error: error,
        })
      })
  }

  return (
    <>
      <div
        className={`tag-container ${showConfirm && "tag-container-disabled"}`}
      >
        <div className="tag-value">{tag.value}</div>
        <div className="tag-actions">
          <SmartLink
            onClick={() => onDeleteClick()}
            style="default"
            size="small"
            disabled={showConfirm}
            isAllowed={canDelete}
            notAllowedText="Not allowed to delete access profiles. Please check with your administrator."
          >
            <span className="fa fa-trash fa-fw"></span>
          </SmartLink>
        </div>
      </div>
      <Collapse in={showConfirm}>
        <div>
          <div className="confirm-remove">
            <div className="text">Are you sure?</div>
            <Button
              bsStyle="danger"
              disabled={deleting}
              bsSize="small"
              onClick={onConfirmDeleteClick}
            >
              {deleting && <span className="spinner"></span>}
              Yes
            </Button>
            <span className="cancel">
              <Button
                disabled={deleting}
                bsStyle="default"
                bsSize="small"
                onClick={() => setShowConfirm(false)}
              >
                Cancel
              </Button>
            </span>
          </div>
        </div>
      </Collapse>
    </>
  )
}

export default Tag
