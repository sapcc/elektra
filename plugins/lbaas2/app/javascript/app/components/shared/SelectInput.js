import React, { useContext, useEffect } from 'react';
import Select from 'react-select';
import { FormContext } from 'lib/elektra-form/components/form_context'

const SelectInput = ({name, isLoading, items, isMulti, onChange, value, defaultValue,  conditionalPlaceholderText, isClearable, conditionalPlaceholderCondition, isDisabled, useFormContext}) => {
  const context = useContext(FormContext)
  const shouldUseContext = useFormContext == false ? false : true

  const onSelectChanged = (props) => {
    let value = null
    if (props) {
      if (isMulti) {
        value =  props.map( (item, index) => item.value)
      } else {
        value = props.value        
      }
    }

    if(shouldUseContext) {context.onChange(name,value)}    
    onChange(props)
  }

  const placeholder = conditionalPlaceholderCondition ? conditionalPlaceholderText : "Select..."

  return ( 
    <Select
    className="basic-single"
    classNamePrefix="select"
    isDisabled={false}
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
    closeMenuOnSelect={isMulti?false:true}
    placeholder={placeholder}
    isDisabled={isDisabled}
  />
   );
}
 
export default SelectInput;