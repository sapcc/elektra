import { Modal, Button, Tabs, Tab } from 'react-bootstrap';
import { Link } from 'react-router-dom'
import ReactJson from 'react-json-view'

export default class ShowSearchObjectModal extends React.Component{
  state = {
    show: true,
    isFetching: false,
    error: null
  }

  componentDidMount = () => {
    // load object if it does not exist
    if(!this.props.item && this.props.match.params.id) {
      this.setState({isFetching: true}, () =>
        this.props.load(this.props.match.params.id).catch((error) =>
          this.setState({isFetching: false, error})
        )
      )
    }
  }

  componentWillReceiveProps = (props) => {
    if(props.item) {
      this.setState({show: true, isFetching: false, error: null})
    }
  }

  restoreUrl = (e) => {
    if (!this.state.show)
      this.props.history.replace('/search')
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({show: false})
  }

  render(){
    const { item } = this.props

    return (
      <Modal
        show={this.state.show}
        onExited={this.restoreUrl}
        onHide={this.hide}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Show object {item ? item.cached_object_type : ''}
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          { this.state.isFetching &&
            <React.Fragment><span className='spinner'/>Loading...</React.Fragment>}
          { this.state.error && <span>{this.state.error}</span>}
          { item &&
            <React.Fragment>
              <Tabs defaultActiveKey={1} id="item_payload">
                <Tab eventKey={1} title="Formatted">
                  <ReactJson src={item.payload} collapsed={1}/>
                </Tab>
                <Tab eventKey={2} title="Raw">
                  <pre>{JSON.stringify(item.payload, null, 2)}</pre>
                </Tab>
              </Tabs>
              {item.cached_object_type == 'project' &&
                <a
                  href={`/${item.domain_id}/${item.id}/home`}
                  target='_blank'
                  className='btn btn-primary'>
                  Switch to Project
                </a>
              }
            </React.Fragment>
          }
        </Modal.Body>
        <Modal.Footer>
          <Button onClick={this.hide}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
