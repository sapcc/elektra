import { ErrorsList } from "./errors_list"
import React, { useContext } from "react"
import { FormContext } from "./form_context"

export const FormErrors = ({
  className = "alert alert-error",
  ...otherProps
}) => {
  const context = useContext(FormContext)

  // return null if no errors given
  let localErrors = otherProps["errors"] || context.formErrors

  if (!localErrors) return null

  return (
    <div className={className}>
      <ErrorsList errors={localErrors} />
    </div>
  )
}
