import { Form } from 'elektra-form';

export default class NewSecurityServiceForm extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {};
  }

  render(){
    return (
      <Form
        validate={()=>true}
        className='form form-inline'
        onSubmit={this.props.handleSubmit}>

        { this.props.shareNetwork &&
          <div>`Network: ${shareNetwork.cidr}`</div>
        }

        <Form.Errors/>

        <Form.ElementInline label='Security Service' name="id">
          <Form.Input elementType='select'>
            <option value=''>Select Security Service</option>
            { availableSecurityServices.map(securityService =>
              <option key={securityService.id} value={securityService.id}>
                {"securityService.name (${securityService.type})"}
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
}
