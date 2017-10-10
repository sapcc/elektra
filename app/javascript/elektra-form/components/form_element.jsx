export const FormElement = ({label, required = false, htmlFor, children}) => {
  return (
    <div className="form-group">
      <label className={`text $(required ? 'required' : 'optional') col-sm-4 control-label`} htmlFor={htmlFor}>
        { required && <abbr title="required">*</abbr>}
        {label}
      </label>
      <div className="col-sm-8">
        <div className="input-wrapper">{children}</div>
      </div>
    </div>
  )
};
