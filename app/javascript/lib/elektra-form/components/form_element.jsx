import { useContext } from 'react'
import { FormContext } from './form_context'

export const FormElement = ({
  label,
  required = false,
  name,
  horizontal=false,
  inline=false,
  labelWidth=4, //columns, maximum 12
  labelClass='control-label',
  children
}) => {
  
  const context = useContext(FormContext)
  //console.log("FormElement->context",context)

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
    return (
      <label className={className} htmlFor={id}>
        { required && <abbr title="required">*</abbr>}
        {label}
      </label>
    )
  };

  const childName = (child) => child.props ? child.props.name : name

  let renderChildren = () => 
    React.Children.map(children,
     (child) => {
       return typeof child === 'string' ? child : React.cloneElement(child, {name: childName(child)})
     }
    );
  ;

  let renderInputWrapper = () => (
    inline ? renderChildren() : (
      <div className="input-wrapper">{renderChildren()}</div>
    )
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

export const FormElementHorizontal = (props) =>
  <FormElement horizontal={true} {...props}/>
;

export const FormElementInline = (props) =>
  <FormElement inline={true} {...props}/>
;
