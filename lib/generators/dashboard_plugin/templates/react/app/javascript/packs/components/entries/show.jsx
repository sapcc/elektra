import { Modal, Button } from 'react-bootstrap';

const Row = ({label,value,children}) => {
  return (
    <tr>
      <th style={{width: '30%'}}>{label}</th>
      <td>{value || children}</td>
    </tr>
  )
};

export default class ShowEntryModal extends React.Component{
  constructor(props){
  	super(props);
  	this.state = {show: props.entry!=null};
    this.close = this.close.bind(this)
  }

  close(e) {
    if(e) e.stopPropagation()
    //this.props.history.goBack()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/entries'),300)
  }

  render(){
    let { entry, onHide } = this.props

    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">Entry {entry ? entry.name : ''}</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          { entry &&
            <table className='table no-borders'>
              <tbody>
                <Row label='Name' value={entry.name}/>
                <Row label='Description' value={entry.description}/>
                <Row label='ID' value={entry.id}/>
              </tbody>
            </table>
          }
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.close}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
