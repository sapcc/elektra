import { Button } from 'react-bootstrap';
import { FormContext } from './form_context'
import { useContext } from 'react'

export const SubmitButton = ({label='Save'}) => {
  const context = useContext(FormContext)

  return (
    <Button bsStyle="primary" type="submit" disabled={!context.isFormValid || context.isFormSubmitting}>
      { context.isFormSubmitting ? 'Please Wait ...' : label }
    </Button>
  )
};
