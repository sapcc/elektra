import React, { useContext, useState, useEffect } from "react"
import CreatableSelect from "react-select/creatable"
import { FormContext } from "lib/elektra-form/components/form_context"
import ipRegex from "ip-regex"
import uniqueId from "lodash/uniqueId"

const styles = {
  multiValue: (base, state) => {
    if (state?.data?.isFixed == false) {
      return  { ...base, backgroundColor: "gray" }
    } else if (state?.data?.isValid == false) {
      return { ...base, backgroundColor: "#d9534f" }
    } 
    return base
    
    // return state.data.isFixed ? { ...base, backgroundColor: "gray" } : base
  },
  multiValueLabel: (base, state) => {
    return state.data.isFixed
      ? { ...base, fontWeight: "bold", color: "white", paddingRight: 6 }
      : base
  },
  multiValueRemove: (base, state) => {
    return state.data.isFixed ? { ...base, display: "none" } : base
  },
}

const components = {
  DropdownIndicator: null,
}

const createOptions = (options = []) => {
  // init input with values
  let newValues = []
  options.forEach((item) => {
    if (typeof item == "string") {
      newValues.push(createOption(item))
    } else {
      newValues.push(item)
    }
  })
  return newValues
}

const createOption = (label) => {
  return {
    id: uniqueId("cidr-"),
    label,
    value: label,
    isValid: true,
  }
}

// check if the given value is a valid IPv4 or IPv6 cidr
const isValidCidr = (value) => {
  const v4str = `${ipRegex.v4().source}\\/(3[0-2]|[12]?[0-9])`;
  const v6str = `${ipRegex.v6().source}\\/(12[0-8]|1[01][0-9]|[1-9]?[0-9])`;
  return new RegExp(`(?:^${v4str}$)|(?:^${v6str}$)`).test(value);
}


const CidrsInput = ({ name, initValue, onChange, useFormContext }) => {
  const [runInit, setRunInit] = useState(false)
  const [itemEditorInputValue, setItemEditorInputValue] = useState("")
  const [itemEditorValue, setItemEditorValue] = useState([])
  const context = useContext(FormContext)
  const shouldUseContext = useFormContext == false ? false : true

  // this should run only once
  useEffect(() => {
    if (!shouldUseContext && !runInit ) {
      setRunInit(true)
      initItems(initValue || null)
    } 
  }, [initValue])

  useEffect(() => {
    // context is available within a form. No need to wait
    // do not wait until the context changes to init the items
    // otherwise it will overwrite the values until runInit changes
    if (shouldUseContext && !runInit) {
      setRunInit(true)
      initItems(context?.formValues?.allowed_cidrs || null)
    }
         
  }, [context])

  useEffect(() => {
    // do not filter invalid items for now => itemEditorValue.filter((v) => v.isValid)
    if (itemEditorValue) {
      if (shouldUseContext) {
        const newValues = itemEditorValue.map((value) => value.value)
        context.onChange(name, newValues?.length > 0 ? newValues : null)
      }
      if (onChange) {
        onChange(itemEditorValue)
      }
    }
  }, [itemEditorValue])

  const initItems = (values) => {
    // no need to initialize in case of empty array
    if (!values || values.length == 0) {
      return
    }
    // init input with values
    const newValues = createOptions(values)
    setItemEditorValue(newValues)
    setItemEditorInputValue("")
  }

  const addNewItem = (item) => {
    //check if the item is an object or a string
    if (typeof item == "string") {
      item = createOption(item)
    }
    // check for a valid cidr
    if (!isValidCidr(item.value)) {
      item.isValid = false
    }

    const newItems = [...itemEditorValue, item]
    setItemEditorValue(newItems)   
  }

  // on remove item
  const onItemEditorChange = (value, { action, removedValue }) => {
    switch (action) {
      case "remove-value":
      case "pop-value":
        // don't remove items that are fixed
        if (removedValue && removedValue.isFixed) {
          return
        }
        break
      case "clear":
        // clear all items
        value = itemEditorValue.filter((v) => v.isFixed)
        break
    }
    const newItems = value || []
    setItemEditorValue(newItems)
  }

  // save what the user entered before hitting enter or tab
  const onItemEditorInputChange = (inputValue) => {
    setItemEditorInputValue(inputValue)
  }

  // create new item when user hits enter or tab
  const onItemEditorKeyDown = (event) => {
    if (!itemEditorInputValue) return
    switch (event.key) {
      case "Enter":
      case "Tab":
        addNewItem(itemEditorInputValue)
        setItemEditorInputValue("")
        event.preventDefault()
    }
  }  

  return (
    <>
      <CreatableSelect
        styles={styles}
        components={components}
        inputValue={itemEditorInputValue}
        isClearable
        isMulti
        menuIsOpen={false}
        onChange={onItemEditorChange}
        onInputChange={onItemEditorInputChange}
        onKeyDown={onItemEditorKeyDown}
        placeholder=""
        value={itemEditorValue}
      />
      {/* filter cidrs not valid */}      
      {itemEditorValue.filter((v) => !v.isValid).map((v) => (
        <div className="text-danger" key={v.id}>
          {v.value} seems not to be a valid CIDR
        </div>
      ))}      

    </>
  )
}

export default CidrsInput
