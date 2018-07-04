import { Modal, Button } from 'react-bootstrap';
import { Form } from 'lib/elektra-form';
import { Link } from 'react-router-dom';
import ipRangeCheck from 'ip-range-check';

const FormBody = ({values, networks, subnets, securityGroups}) => {
  let network_subnets = []
  if (values.network_id && subnets.items && subnets.items.length>0) {
    for(let i in subnets.items) {
      let subnet = subnets.items[i]
      if(subnet.network_id==values.network_id) network_subnets.push(subnet)
    }
  }

  return (
    <Modal.Body>
      <Form.Errors/>

      <Form.ElementHorizontal label='Network' required={true} name="network_id">
        { networks.isFetching ?
          <span className='spinner'/>
          :
          <Form.Input
            elementType='select'
            className="select required form-control"
            name='network_id'>
            <option></option>
            {networks.items.map((network,index) =>
              <option value={network.id} key={index}>
                {network.name}
              </option>
            )}
          </Form.Input>
        }
      </Form.ElementHorizontal>

      <Form.ElementHorizontal label='Subnet' required={true} name="subnet_id">
        { subnets.isFetching ?
            <span className='spinner'/>
          :
            <Form.Input
              elementType='select'
              className="select required form-control"
              name='subnet_id'>
              <option></option>

              {network_subnets.map((subnet,index) =>
                <option value={subnet.id} key={index}>
                  {`${subnet.name} (${subnet.cidr})`}
                </option>
              )}
            </Form.Input>
        }
      </Form.ElementHorizontal>

      <Form.ElementHorizontal label='IP' name="ip_address">
        <Form.Input elementType='input' type='text' name='ip_address'/>
      </Form.ElementHorizontal>

      {securityGroups && securityGroups.items && securityGroups.items.length>0 &&
        <Form.ElementHorizontal label='Security Groups' name="security_groups">
          <Form.FormMultiselect
            name="security_groups"
            options={securityGroups.items}
            showSelectedLabel={true}
            selectedLabelLength={3}
            showIDs
          />
        </Form.ElementHorizontal>
      }

      <Form.ElementHorizontal label='Description' name="description">
        <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
      </Form.ElementHorizontal>

    </Modal.Body>
  )
}

export default class NewPortForm extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {show: true};
    this.close = this.close.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
    this.validate = this.validate.bind(this)
  }

  componentDidMount() {
    this.loadDependencies(this.props)
  }

  componentWillReceiveProps(nextProps) {
    this.loadDependencies(nextProps)
  }

  loadDependencies(props) {
    props.loadNetworksOnce()
    props.loadSubnetsOnce()
    props.loadSecurityGroupsOnce()
  }


  validate(values) {
    let subnet = this.props.subnets.items.find((s) => s.id==values.subnet_id)
    return values.network_id && values.subnet_id && values.ip_address &&
           ipRangeCheck(values.ip_address, subnet.cidr) && true
  }

  close(e){
    if(e) e.stopPropagation()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/ports'),300)
  }

  onSubmit(values){
    return this.props.handleSubmit(values).then(() => this.close());
  }

  render(){
    let defaultOptions = []
    if(this.props.securityGroups && this.props.securityGroups.items) {
      defaultOptions = this.props.securityGroups.items.filter(i =>
        i.name == 'default'
      ).map(i => i.id)
    }

    const initialValues = defaultOptions.length >0 ? {security_groups: defaultOptions} : null

    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">New Fixed IP Reservation</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}
          initialValues={initialValues}>

          <FormBody
            networks={this.props.networks}
            subnets={this.props.subnets}
            securityGroups={this.props.securityGroups}/>

          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
