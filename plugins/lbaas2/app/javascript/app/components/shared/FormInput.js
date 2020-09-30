import React, { useContext, useEffect, useState } from "react"
import { FormContext } from "lib/elektra-form/components/form_context"

// size: md, sm
const FormInput = ({ type, name, placeholder, value, disabled, size }) => {
  const context = useContext(FormContext)
  const [checkboxValue, setCheckboxValue] = useState(false)

  const getRandomInt = (max) => {
    return Math.floor(Math.random() * Math.floor(max))
  }

  useEffect(() => {
    // in case of checkboxes init the state
    setCheckboxValue(inputType == "checkbox" ? value : false)
    // init the context with the values
    setTimeout(() => {
      context.onChange(name, value), getRandomInt(200)
    })
  }, [value])

  const onTextChanged = (e) => {
    const target = e.target
    const newValue = target.type === "checkbox" ? target.checked : target.value
    const newName = target.name
    // update checkbox check since it is set directly on the input tag
    setCheckboxValue(inputType == "checkbox" ? newValue : false)
    context.onChange(newName, newValue)
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
        checked={checkboxValue}
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
