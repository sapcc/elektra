//import React from 'react';
import PropTypes from 'prop-types';

export const FormInput = ({
  elementType,
  id,
  className='',
  required=false,
  name,
  children,
  ...otherProps
},context) => {
  let values = context.formValues || {}
  let isValid = true;
  if (context.formErrors &&
    (typeof context.formErrors === 'object') &&
    context.formErrors[name]) {
      isValid = false;
  }

  let inputProps = {
    className: `form-control ${required ? 'required' : 'optional'} ${isValid ? '' : 'is-invalid'} ${className}`,
    name,
    id: id || (context.formName ? context.formName + '_' + name : name),
    value: values[name] || '',
    onChange: (e) => { e.preventDefault(); context.onChange(e.target.name,e.target.value)},
    ...otherProps
  }

  return (
    <React.Fragment>{React.createElement(elementType, inputProps, children)}</React.Fragment>
  )
};

FormInput.contextTypes = {
  formName: PropTypes.string,
  formValues: PropTypes.object,
  onChange: PropTypes.func,
  formErrors: PropTypes.oneOfType([PropTypes.string, PropTypes.object, PropTypes.array])
};
