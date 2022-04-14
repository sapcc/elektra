import { Form } from 'lib/elektra-form';

export default (props) => {
  return (
    <Form
      validate={()=>true}
      className='form form-inline'
      onSubmit={props.handleSubmit}>

      <Form.Errors/>

      <Form.ElementInline label='Security Service' name="id" labelClass='sr-only'>
        <Form.Input elementType='select'>
          <option value=''>Select Security Service</option>
          { props.availableSecurityServices.map(securityService =>
            <option key={securityService.id} value={securityService.id}>
              { `${securityService.name} (${securityService.type})` }
            </option>
          )}
        </Form.Input>
      </Form.ElementInline>

      <div className='form-group'>
        <Form.SubmitButton label='Add'/>
      </div>
    </Form>
  )
}
