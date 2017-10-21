import PropTypes from 'prop-types';

export const FormElement = ({
  label,
  required = false,
  name,
  horizontal=false,
  inline=false,
  labelWidth=4, //columns, maximum 12
  labelClass='control-label',
  children
},context) => {
  let id = context.formName ? context.formName + '_' + name : name;
  let isValid = true;
  if (context.formErrors &&
    (typeof context.formErrors === 'object') &&
    context.formErrors[name]) {
      isValid = false;
  }

  let renderLabel = () => {
    let className = labelClass + ' ' +(required ? 'required' : 'optional')
    if (horizontal) className = className + ` col-sm-${labelWidth}`
    return <label className={className} htmlFor={id}>
      { required && <abbr title="required">*</abbr>}
      {label}
    </label>
  };

  let renderInputWrapper = () => (
    inline ? children : <div className="input-wrapper">{children}</div>
  );

  return (
    <div className={`form-group ${inline ? '' : 'row'} ${isValid ? '' : 'has-error'}`}>
      { renderLabel() }
      { horizontal ?
        <div className={`col-sm-${12-labelWidth}`}>{renderInputWrapper()}</div>
        : renderInputWrapper()
      }
    </div>
  )
};

FormElement.contextTypes = {
  formName: PropTypes.string,
  formErrors: PropTypes.oneOfType([PropTypes.string, PropTypes.object, PropTypes.array])
};
export const FormElementHorizontal = (props) =>
  <FormElement horizontal={true} {...props}/>
;

export const FormElementInline = (props) =>
  <FormElement inline={true} {...props}/>
;
