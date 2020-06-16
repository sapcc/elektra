import React, { useContext } from 'react';
import Select from 'react-select';
import { FormContext } from 'lib/elektra-form/components/form_context'

const SelectInput = ({name, isLoading, items, isMulti, onChange, value, conditionalPlaceholderText, isClearable, conditionalPlaceholderCondition, isDisabled}) => {

  const context = useContext(FormContext)

  const onSelectChanged = (props) => {
    if (props) {
      if (isMulti) {
        const values =  props.map( (item, index) => item.value)
        context.onChange(name,values)
      } else {
        context.onChange(name,props.value)
      }
    }
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
    isMulti={isMulti}
    closeMenuOnSelect={isMulti?false:true}
    placeholder={placeholder}
    isDisabled={isDisabled}
  />
   );
}
 
export default SelectInput;