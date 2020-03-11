import React, { useContext, useState } from 'react';
import CreatableSelect from 'react-select/creatable';
import { FormContext } from 'lib/elektra-form/components/form_context'

const TagsInput = ({name}) => {
  const context = useContext(FormContext)

  const components = {
    DropdownIndicator: null,
  };

  const createOption = (label) => {
    return {
      label,
      value: label,
    }
  }

  const [tagEditorInputValue, setTagEditorInputValue] = useState("")
  const [tagEditorValue, setTagEditorValue] = useState([])

  const onTagEditorChange = (value, actionMeta) => {
    setTagEditorValue(value || [])
  }

  const onTagEditorInputChange = (inputValue) => {
    setTagEditorInputValue(inputValue)
    //send the tags to the context
    const tags = tagEditorValue.map( (value, index) => value.value )    
    context.onChange(name,tags)
  }

  const onTagEditorKeyDown = (event) => {
    if (!tagEditorInputValue) return;
    switch (event.key) {
      case 'Enter':
      case 'Tab':
        setTagEditorValue([...tagEditorValue, createOption(tagEditorInputValue)])
        setTagEditorInputValue("")  
        event.preventDefault();
    }
  };

  return ( 
    <CreatableSelect
      components={components}
      inputValue={tagEditorInputValue}
      isClearable
      isMulti
      menuIsOpen={false}
      onChange={onTagEditorChange}
      onInputChange={onTagEditorInputChange}
      onKeyDown={onTagEditorKeyDown}
      placeholder=""
      value={tagEditorValue}
    />
   );
}
 
export default TagsInput;