import { Button } from 'react-bootstrap';
import { FormContext } from 'lib/elektra-form/components/form_context'
import { useContext } from 'react'

const FormSubmitButton = ({label='Save', disabled = null}) => {
  const context = useContext(FormContext)

  const isDisabled = () => {
    if(disabled != null) {
      return disabled
    } 
    return !context.isFormValid || context.isFormSubmitting
  }

  return (
    <Button bsStyle="primary" type="submit" disabled={isDisabled()}>
      { context.isFormSubmitting ? 'Please Wait ...' : label }
    </Button>
  )
};

export default FormSubmitButton