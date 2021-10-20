import React, { useContext, useState, useEffect } from "react";
import CreatableSelect from "react-select/creatable";
import { FormContext } from "lib/elektra-form/components/form_context";

const TagsInput = ({ name, initValue, onChange, useFormContext }) => {
  const [tagEditorInputValue, setTagEditorInputValue] = useState("");
  const [tagEditorValue, setTagEditorValue] = useState([]);
  const [tags, setTags] = useState(null);
  const context = useContext(FormContext);
  const shouldUseContext = useFormContext == false ? false : true;

  useEffect(() => {
    initTags();
  }, [initValue]);

  useEffect(() => {
    if (tags) {
      updateContext();
      onChangeCallback();
    }
  }, [tags]);

  const initTags = () => {
    // no need to initialize in case of empty array
    if (!initValue || initValue.length == 0) {
      return;
    }
    // init input with values
    const newValues = createOptions(initValue);
    setTagEditorValue(newValues);
    setTagEditorInputValue("");
  };

  const createOptions = (options = []) => {
    // init input with values
    let newValues = [];
    options.forEach((item) => {
      if (typeof item == "string") {
        newValues.push(createOption(item));
      } else {
        newValues.push(item);
      }
    });
    return newValues;
  };

  const styles = {
    multiValue: (base, state) => {
      return state.data.isFixed ? { ...base, backgroundColor: "gray" } : base;
    },
    multiValueLabel: (base, state) => {
      return state.data.isFixed
        ? { ...base, fontWeight: "bold", color: "white", paddingRight: 6 }
        : base;
    },
    multiValueRemove: (base, state) => {
      return state.data.isFixed ? { ...base, display: "none" } : base;
    },
  };

  const components = {
    DropdownIndicator: null,
  };

  const createOption = (label) => {
    return {
      label,
      value: label,
    };
  };

  const createNewTag = () => {
    const newTags = [...tagEditorValue, createOption(tagEditorInputValue)];
    setTagEditorValue(newTags);
    setTags(newTags.map((value, index) => value.value));
    setTagEditorInputValue("");
  };

  const updateContext = () => {
    if (shouldUseContext) {
      context.onChange(name, tags);
    }
  };

  const onChangeCallback = () => {
    if (onChange) {
      onChange(tagEditorValue);
    }
  };

  const onTagEditorChange = (value, { action, removedValue }) => {
    switch (action) {
      case "remove-value":
      case "pop-value":
        // add check removedValue in case you hit delete key until nothing is in the field
        if (removedValue && removedValue.isFixed) {
          return;
        }
        break;
      case "clear":
        value = tagEditorValue.filter((v) => v.isFixed);
        break;
    }
    const newTags = value || [];
    setTagEditorValue(newTags);
    setTags(newTags.map((value, index) => value.value));
  };

  const onTagEditorInputChange = (inputValue) => {
    setTagEditorInputValue(inputValue);
  };

  const onTagEditorKeyDown = (event) => {
    if (!tagEditorInputValue) return;
    switch (event.key) {
      case "Enter":
      case "Tab":
        createNewTag();
        event.preventDefault();
    }
  };

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
      value={tagEditorValue}
    />
  );
};

export default TagsInput;
