import PropTypes from 'prop-types';
import { ErrorsList } from './errors_list';

export const FormErrors = ({
  className='alert alert-error',
  ...otherProps
},context) => {
  // return null if no errors given
  let lokalErrors = otherProps['errors'] || context.formErrors;
  if (!lokalErrors) return null;

  return (
    <div className={className}><ErrorsList errors={lokalErrors}/></div>
  )
};

FormErrors.contextTypes = {
  formErrors: PropTypes.oneOfType([PropTypes.string, PropTypes.object, PropTypes.array])
};
