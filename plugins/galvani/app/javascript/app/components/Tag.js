import React, { useEffect, useState } from "react"
import SmartLink from "./shared/SmartLink"
import { Button, Collapse } from "react-bootstrap"
import { removeTag } from "../actions/tags"

const Tag = ({ tag }) => {
  const [showConfirm, setShowConfirm] = useState(false)
  const canDelete = true

  const onDeleteClick = () => {
    setShowConfirm(true)
  }

  const onConfirmDeleteClick = () => {
    console.log("remove tag: ", tag.value)
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
              bsSize="small"
              onClick={onConfirmDeleteClick}
            >
              Yes
            </Button>
            <span className="cancel">
              <Button
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
