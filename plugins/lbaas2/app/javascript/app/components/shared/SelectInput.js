import React, { useContext } from 'react';
import Select from 'react-select';
import { FormContext } from 'lib/elektra-form/components/form_context'

const SelectInput = ({name, isLoading, items, onChange, value, conditionalPlaceholderText, conditionalPlaceholderCondition}) => {

  const context = useContext(FormContext)

  const onSelectChanged = (props) => {
    if (props) {
      context.onChange(name,props.value)
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
    // isClearable={true}
    isRtl={false}
    isSearchable={true}
    name="vip_subnet"
    onChange={onSelectChanged}
    options={items}
    value={value}
    placeholder={placeholder}
  />
   );
}
 
export default SelectInput;