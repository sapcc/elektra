import { useState } from "react"
import Clipboard from "react-clipboard.js"
import React from "react"
//This component can be used to display a simple one-line text. When hovered,
//an overlay is shown that allows to copy text. Params:
//
//  shortText - the text to display while not hovered (either equal to or a shortened form of longText)
//  longText - the text to display while hovered
//  actions - an array of entries like { "label": "Copy full URL", "value": "http://example.org" }
//
const HoverCopier = ({ shortText, longText, actions }) => {
  const [copiedLabel, setCopiedLabel] = useState("")
  if (copiedLabel) {
    setTimeout(() => setCopiedLabel(""), 3000)
  }

  return (
    <span className="hover-copier">
      {shortText}
      <span className="hover-copier-expanded">
        {longText}
        <br />
        <span className="hover-copier-actions">
          {actions.map((action) =>
            copiedLabel == action.label ? (
              <button
                key={action.label}
                className="btn btn-link btn-xs"
                disabled={true}
              >
                <i className="fa fa-copy fa-fw"></i> Copied!
              </button>
            ) : (
              <Clipboard
                key={action.label}
                className="btn btn-link btn-xs"
                data-clipboard-text={action.value}
                onSuccess={() => setCopiedLabel(action.label)}
              >
                <i className="fa fa-copy fa-fw"></i> {action.label}
              </Clipboard>
            )
          )}
        </span>
      </span>
    </span>
  )
}

export default HoverCopier
