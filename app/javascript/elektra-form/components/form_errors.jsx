import PropTypes from 'prop-types';

export const FormErrors = ({
  className='alert alert-error'
},context) => {
  if (!context.formErrors) return null;
  return (
    <div className={className}>
      Errors
    </div>
  )
};

FormErrors.contextTypes = {
  formErrors: PropTypes.object
};
