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
  let inputProps = {
    className: `form-control ${required ? 'required' : 'optional'} ${className}`,
    name,
    id: id || context.formName + '_' +name,
    value: values[name] || '',
    onChange: (e) => { e.preventDefault(); context.onChange(e.target.name,e.target.value)},
    ...otherProps
  }

  return (
    React.createElement(elementType, inputProps, children)
  )
};

FormInput.contextTypes = {
  formName: PropTypes.string,
  formValues: PropTypes.object,
  onChange: PropTypes.func
};
