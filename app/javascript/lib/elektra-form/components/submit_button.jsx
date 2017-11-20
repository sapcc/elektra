import PropTypes from 'prop-types';
import { Button } from 'react-bootstrap';

export const SubmitButton = ({label='Save'},context) => {
  return (
    <Button bsStyle="primary" type="submit" disabled={!context.isFormValid || context.isFormSubmitting}>
      { context.isFormSubmitting ? 'Please Wait ...' : label }
    </Button>
  )
};

SubmitButton.contextTypes = {
  formName: PropTypes.string,
  isFormSubmitting: PropTypes.bool,
  isFormValid: PropTypes.bool
};
