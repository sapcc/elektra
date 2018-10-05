import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';
import {
  SECURITY_GROUP_RULE_DESCRIPTIONS,
  SECURITY_GROUP_RULE_PREDEFINED_TYPES,
  SECURITY_GROUP_RULE_PROTOCOLS
} from '../../constants'

const FormBody = ({values}) =>
  <Modal.Body>
    <div className="row">
      <div className="col-sm-6">
        <Form.Errors/>


        <Form.ElementInline label='Name' name="name" required>
          <Form.Input elementType='input' type='text' name='name'/>
        </Form.ElementInline>

        <Form.ElementInline label='Name' name="name" required>
          <Form.Input elementType='input' type='text' name='name'/>
        </Form.ElementInline>

        <Form.ElementInline label='Name' name="name" required>
          <Form.Input elementType='input' type='text' name='name'/>
        </Form.ElementInline>

        <Form.ElementInline label='Name' name="name" required>
          <Form.Input elementType='input' type='text' name='name'/>
        </Form.ElementInline>

        <Form.ElementInline label='Name' name="name" required>
          <Form.Input elementType='input' type='text' name='name'/>
        </Form.ElementInline>

        <Form.ElementInline label='Name' name="name" required>
          <Form.Input elementType='input' type='text' name='name'/>
        </Form.ElementInline>

        <Form.ElementInline label='Description' name="description">
          <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
        </Form.ElementInline>
      </div>

      <div className="col-sm-6">
        <div className="bs-callout bs-callout-primary small">
          {SECURITY_GROUP_RULE_DESCRIPTIONS.map((description,index) =>
            <React.Fragment key={index}>
              {description.title!='Rules' && <h4>{description.title}</h4>}
              <p>{description.text}</p>
            </React.Fragment>
          )}
        </div>
      </div>
    </div>

  </Modal.Body>

export default class NewRuleForm extends React.Component {
  state = { show: true }

  validate = (values) => {
    return values.name && true
  }

  close = (e) => {
    if(e) e.stopPropagation()
    this.setState({show: false})
  }

  restoreUrl = (e) => {
    if (!this.state.show)
      this.props.history.replace(`/security-groups/${this.props.securityGroupId}/rules`)
  }

  onSubmit = (values) =>{
    return this.props.handleSubmit(values).then(() => this.close());
  }

  render(){
    const initialValues = {}

    return (
      <Modal
        show={this.state.show}
        onHide={this.close}
        bsSize="large"
        dialogClassName="modal-xl"
        backdrop='static'
        onExited={this.restoreUrl}
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">New Security Group Rule</Modal.Title>
        </Modal.Header>

        <Form
          className='form'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}>

          <FormBody/>

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
