import { Modal, Button, Tabs, Tab } from 'react-bootstrap';
import { Link } from 'react-router-dom'
import ReactJson from 'react-json-view'
import projectUrl from '../../shared/project_link'
import ProjectUserRoles from '../../role_assignments/containers/project_user_roles'

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
    if (!this.state.show) this.props.history.goBack();
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({show: false})
  }

  render(){
    const { item } = this.props
    const projectLink = projectUrl(item)
    const found = this.props.location.search.match(/\?tab=([^\&]+)/)
    const activeTab = found ? found[1] : null

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
              <Tabs defaultActiveKey={activeTab || 'data'} id="item_payload">
                <Tab eventKey='data' title="Data">
                  <ReactJson src={item.payload} collapsed={1}/>
                </Tab>

                { item.cached_object_type=='project' &&
                  <Tab eventKey='roles' title="User Role Assignments">
                    <ProjectUserRoles project={item}/>
                  </Tab>
                }
              </Tabs>
            </React.Fragment>
          }
        </Modal.Body>
        <Modal.Footer>
          {projectLink &&
            <a
              href={projectLink}
              target='_blank'
              className='btn btn-primary'>
              Switch to Project
            </a>
          }
          <Button onClick={this.hide}>Close</Button>
        </Modal.Footer>
      </Modal>
    )
  }
}
