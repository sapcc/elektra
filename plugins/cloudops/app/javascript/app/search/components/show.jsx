import { Modal, Button, Tabs, Tab } from 'react-bootstrap';
import { Link } from 'react-router-dom'
import ReactJson from 'react-json-view'
import { projectUrl, objectUrl } from '../../shared/object_link_helper'

import ProjectRoleAssignments from '../../../../../../identity/app/javascript/role_assignments/containers/project_role_assignments'
import NetworkUsageStats from '../../../../../../networking/app/javascript/network_usage_stats/containers/application'

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
    if(this.state.show) return;

    if(this.props.match && this.props.match.path) {
      const found = this.props.match.path.match(/(\/[^\/]+)\/:id\/show/)
      if(found) {
        this.props.history.replace(found[1])
        return
      }
    }

    this.props.history.goBack();
  }

  hide = (e) => {
    if (e) e.stopPropagation()
    this.setState({show: false})
  }

  render(){
    const { item } = this.props
    const projectLink = projectUrl(item)
    const objectLink = objectUrl(item)
    const found = this.props.location.search.match(/\?tab=([^\&]+)/)
    const activeTab = found ? found[1] : null
    const isProject = item && item.cached_object_type == 'project'
    const isDomain = item && item.cached_object_type == 'domain'

    return (
      <Modal
        show={this.state.show}
        onExited={this.restoreUrl}
        onHide={this.hide}
        bsSize="large"
        aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">
            Show {item &&
              <React.Fragment>
                {item.cached_object_type} {item.name} ({item.id})
              </React.Fragment>
            }
          </Modal.Title>
        </Modal.Header>
        <Modal.Body>
          { this.state.isFetching &&
            <React.Fragment><span className='spinner'/>Loading...</React.Fragment>}
          { this.state.error && <span>{this.state.error}</span>}
          { item &&
            <Tabs defaultActiveKey={activeTab || 'data'} id="item_payload" mountOnEnter>
              <Tab eventKey='data' title="Data">
                <ReactJson src={item.payload} collapsed={1}/>
              </Tab>
              { isProject &&
                <Tab eventKey='userRoles' title="User Role Assignments">
                  <ProjectRoleAssignments
                    projectId={item.id}
                    projectDomainId={item.domain_id}
                    type='user'
                  />
                </Tab>
              }
              { isProject &&
                <Tab eventKey='groupRoles' title="Group Role Assignments">
                  <ProjectRoleAssignments
                    projectId={item.id}
                    projectDomainId={item.domain_id}
                    type='group'
                  />
                </Tab>
              }
              { (isProject || isDomain) &&
                <Tab eventKey='networkStats' title="Network Statistics">
                  <NetworkUsageStats
                    scopeId={item.id}
                    scopeType={isProject ? 'project' : 'domain'}
                  />
                </Tab>
              }
            </Tabs>
          }
        </Modal.Body>
        <Modal.Footer>
          {objectLink &&
            <a
              href={objectLink}
              target='_blank'
              className='btn btn-primary'>
              Show in Elektra
            </a>
          }

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
