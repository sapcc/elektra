import React, { useContext, useState,useEffect } from 'react';
import CreatableSelect from 'react-select/creatable';
import { FormContext } from 'lib/elektra-form/components/form_context'

/*
* initValue: initialize the tags array
* predTags: Add predefined tags decoupled from the editor array. Add them as fixed options.
*/
const TagsInput = ({name, initValue, predTags}) => {
  const [tagEditorInputValue, setTagEditorInputValue] = useState("")
  const [tagEditorValue, setTagEditorValue] = useState([])
  const [predefinedTags, setPredefinedTags] = useState([])
  const context = useContext(FormContext)

  useEffect(() => {
    initTags()
  }, [initValue])

  useEffect(() => {
    addPredefinedTags()
  }, [predTags])

  useEffect(() => {
    updateContext()
  }, [predefinedTags])

  useEffect(() => {
    updateContext()
  }, [tagEditorValue])

  const initTags = () => {
    // no need to initialize in case of empty array
    if(!initValue || initValue.length == 0) {
      return
    }
    // init input with values
    const newValues = createOptions(initValue)
    setTagEditorValue(newValues)
    setTagEditorInputValue("")
  }

  const addPredefinedTags = () => {
    // no need to do anything
    if(!predTags || predTags.length == 0) {
      return
    }
    // create options
    const newValues = createOptions(predTags)
    setPredefinedTags(newValues)
  }

  const createOptions = (options = []) => {
    // init input with values
    let newValues = []
    options.forEach(item => {
      if (typeof item == 'string') {
        newValues.push(createOption(item))
      } else {
        newValues.push(item)
      }      
    })
    return newValues
  }

  const styles = {
    multiValue: (base, state) => {
      return state.data.isFixed ? { ...base, backgroundColor: 'gray' } : base;
    },
    multiValueLabel: (base, state) => {
      return state.data.isFixed
        ? { ...base, fontWeight: 'bold', color: 'white', paddingRight: 6 }
        : base;
    },
    multiValueRemove: (base, state) => {
      return state.data.isFixed ? { ...base, display: 'none' } : base;
    },
  };

  const components = {
    DropdownIndicator: null,
  };

  const createOption = (label) => {
    return {
      label,
      value: label,
    }
  }

  const createNewTag = () => {
    setTagEditorValue([...tagEditorValue, createOption(tagEditorInputValue)])
    setTagEditorInputValue("")
  }

  const updateContext = () => {
    //send the tags to the context
    const editorTags = tagEditorValue.map( (value, index) => value.value )
    const extraTags = predefinedTags.map( (value, index) => value.value )
    const contextTags = [...extraTags, ...editorTags]
    context.onChange(name, contextTags)
  }

  const onChangeCallback = () => {
    if(onChange) {
      onChange(tagEditorValue)
    }
  }

  const onTagEditorChange = (value, { action, removedValue }) => {
    switch (action) {
      case 'remove-value':
      case 'pop-value':
        if (removedValue.isFixed) {
          return;
        }
        break;
      case 'clear':
        value = tagEditorValue.filter(v => v.isFixed);
        break;
    }
    setTagEditorValue(value || [])
  }

  const onTagEditorInputChange = (inputValue) => {
    setTagEditorInputValue(inputValue)
  }

  const onTagEditorKeyDown = (event) => {
    if (!tagEditorInputValue) return;
    switch (event.key) {
      case 'Enter':
      case 'Tab':
        createNewTag()
        event.preventDefault();
    }
  };

  const tagsValue = [...predefinedTags, ...tagEditorValue]
  return ( 
    <CreatableSelect
      styles={styles}
      components={components}
      inputValue={tagEditorInputValue}
      isClearable
      isMulti
      menuIsOpen={false}
      onChange={onTagEditorChange}
      onInputChange={onTagEditorInputChange}
      onKeyDown={onTagEditorKeyDown}
      placeholder=""
      value={tagsValue}
    />
   );
}
 
export default TagsInput;