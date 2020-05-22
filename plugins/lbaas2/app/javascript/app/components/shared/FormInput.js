import React, { useContext,useEffect, useState } from 'react';
import { FormContext } from 'lib/elektra-form/components/form_context'

const FormInput = ({type, number, name, placeholder, value}) => {
  const context = useContext(FormContext)

  const getRandomInt = (max) => {
    return Math.floor(Math.random() * Math.floor(max));
  }

  useEffect(() => {
    setTimeout(() => context.onChange(name, value),getRandomInt(200))
  }, [value])

  const onTextChanged = (e) => {
    const target = e.target;
    if (target) {
      context.onChange(name,target.value)
    }  
  }

  const inputType = type || "text"

  return ( 
    <React.Fragment>
      <input type={inputType} defaultValue={value} placeholder={placeholder} name={name} id={name} className="form-control" onChange={onTextChanged}/>
    </React.Fragment>
   );
}
 
export default FormInput;