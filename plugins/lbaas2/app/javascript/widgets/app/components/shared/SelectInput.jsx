import React, { useContext, useEffect } from "react"
import Select from "react-select"
import { FormContext } from "lib/elektra-form/components/form_context"

const SelectInput = ({
  name,
  isLoading,
  items,
  isMulti,
  onChange,
  value,
  defaultValue,
  conditionalPlaceholderText,
  isClearable,
  conditionalPlaceholderCondition,
  isDisabled,
  useFormContext,
  isOptionDisabled,
}) => {
  const context = useContext(FormContext)
  const shouldUseContext = useFormContext == false ? false : true

  const onSelectChanged = (props) => {
    let value = null
    if (props) {
      if (isMulti) {
        value = props.map((item, index) => item.value)
      } else {
        value = props.value
      }
    }

    if (shouldUseContext) {
      setTimeout(() => {
        context.onChange(name, value)
      }, 100)
    }
    if (onChange) {
      onChange(props)
    }
  }

  const placeholder = conditionalPlaceholderCondition
    ? conditionalPlaceholderText
    : "Select..."

  return (
    <Select
      className="basic-single"
      classNamePrefix="select"
      isLoading={isLoading}
      isClearable={isClearable}
      isRtl={false}
      isSearchable={true}
      name={name}
      onChange={onSelectChanged}
      options={items}
      value={value}
      defaultValue={defaultValue}
      isMulti={isMulti}
      closeMenuOnSelect={isMulti ? false : true}
      placeholder={placeholder}
      isDisabled={isDisabled}
      isOptionDisabled={isOptionDisabled}
    />
  )
}

export default SelectInput
