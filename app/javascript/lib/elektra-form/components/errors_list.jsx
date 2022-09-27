import React from "react"
export const ErrorsList = (props) => {
  let renderErrors = (errors, level = 0) => {
    if (!errors) return

    if (errors instanceof Array) {
      let lis = errors.map((message, i) => (
        <li key={`${level}_${i}`}>{renderErrors(message, level + 1)}</li>
      ))
      return <ul>{lis}</ul>
    } else if (typeof errors === "object") {
      // errors is an object
      let lis = Object.keys(errors).map((error, i) => {
        return (
          <li key={`${level}_${i}`}>
            {`${error}: `}
            {renderErrors(errors[error], level + 1)}
          </li>
        )
      })
      return <ul>{lis}</ul>
    } else {
      // errors is a string or something else
      return errors
    }
  }

  return <span>{props.errors ? renderErrors(props.errors) : ""}</span>
}
