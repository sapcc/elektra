import React, { useContext, useEffect } from "react"
import { FormContext } from "lib/elektra-form/components/form_context"

// size: md, sm
const FormInput = ({ type, name, placeholder, value, disabled, size }) => {
  const context = useContext(FormContext)

  const getRandomInt = (max) => {
    return Math.floor(Math.random() * Math.floor(max))
  }

  useEffect(() => {
    setTimeout(() => context.onChange(name, value), getRandomInt(200))
  }, [value])

  const onTextChanged = (e) => {
    const target = e.target
    const value = target.type === "checkbox" ? target.checked : target.value
    const name = target.name
    context.onChange(name, value)
  }

  const inputType = type || "text"

  const classNameInput = () => {
    let className = "form-control"
    if (inputType == "checkbox") {
      className = "form-check-input"
    }
    if (size == "md") {
      className = `imput-field-md ${className}`
    }
    if (size == "sm") {
      className = `imput-field-sm ${className}`
    }
    return className
  }

  return (
    <React.Fragment>
      <input
        type={inputType}
        defaultValue={value}
        placeholder={placeholder}
        name={name}
        id={name}
        className={classNameInput()}
        onChange={onTextChanged}
        disabled={disabled}
      />
    </React.Fragment>
  )
}

export default FormInput
