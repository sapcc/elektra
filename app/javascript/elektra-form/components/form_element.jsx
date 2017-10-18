import PropTypes from 'prop-types';

export const FormElement = ({
  label,
  required = false,
  name,
  horizontal=false,
  labelWidth=4, //columns, maximum 12
  labelClass='control-label',
  children
},context) => {
  let id = context.formName + '_' + name;

  let renderLabel = () => {
    let className = required ? 'required' : 'optional'
    if (horizontal) className = className + ` col-sm-${labelWidth} ${labelClass}`
    return <label className={className} htmlFor={id}>
      { required && <abbr title="required">*</abbr>}
      {label}
    </label>
  };

  let renderInputWrapper = () => (
    <div className="input-wrapper">{children}</div>
  );

  return (
    <div className="form-group row">
      { renderLabel() }
      { horizontal ?
        <div className={`col-sm-${12-labelWidth}`}>{renderInputWrapper()}</div>
        : renderInputWrapper()
      }
    </div>
  )
};

FormElement.contextTypes = {
  formName: PropTypes.string
};
export const FormElementHorizontal = (props) =>
  <FormElement horizontal={true} {...props}/>
;
