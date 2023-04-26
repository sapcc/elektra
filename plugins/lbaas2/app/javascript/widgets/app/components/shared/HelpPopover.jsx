import React from "react"
import uniqueId from "lodash/uniqueId"
import { Popover } from "lib/components/Overlay"

const HelpPopover = ({ text }) => {
  return (
    <span className="has-feedback-help">
      <Popover trigger="click" placement="top" content={text}>
        <a className="help-link" href="#" onClick={(e) => e.preventDefault()}>
          <i className="fa fa-question-circle"></i>
        </a>
      </Popover>
    </span>
  )
}

export default HelpPopover
