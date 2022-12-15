/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from "react"
import ReactHelpers from "./helpers"

const ReactFormHelpers = {}

//################ ERRORS RENDERR #################
ReactFormHelpers.Errors = function ({ errors }) {
  if (typeof errors === "object") {
    return (
      <ul>
        {(() => {
          const result = []
          for (var error in errors) {
            var messages = errors[error]
            result.push(
              Array.from(messages).map((message, i) => (
                <li key={i}>
                  ${error}: ${message}
                </li>
              ))
            )
          }
          return result
        })()}
      </ul>
    )
  } else if (typeof errors === "string") {
    return errors
  } else {
    return null
  }
}

ReactFormHelpers.Errors.displayName = "Errors"

//#################### SUBMIT BUTTON #######################
ReactFormHelpers.SubmitButton = function (options) {
  if (options == null) {
    options = {}
  }
  options = ReactHelpers.mergeObjects(
    {
      type: "submit",
      className: "btn-primary",
      label: "Save",
      disable_with: "Please wait...",
      loading: false,
      disabled: true,
      onSubmit() {
        return null
      },
    },
    options
  )

  return React.createElement(
    "button",
    {
      type: "submit",
      onClick(e) {
        e.preventDefault()
        return options.onSubmit()
      },
      className: `btn ${options.className}`,
      disabled: options.loading || options.disabled ? true : false,
    },
    options.loading ? options.disable_with : options.label
  )
}

ReactFormHelpers.SubmitButton.displayName = "SubmitButton"

export default ReactFormHelpers
