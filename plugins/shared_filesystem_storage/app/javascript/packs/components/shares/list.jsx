import { withRouter, Route } from 'react-router-dom'

import NewShare from './new'
import ShowShare from './show'
import ShareItem from './item'

const List = React.createClass({
  getInitialState() {
    let shareId = this.extractShareIdFromLocation(this.props.location)

    return {
      //boolean, indicates whether the new dialog is visible or not
      showNew: (this.props.location.pathname=='/shares/new'),
      //object, if set a modal show window is visible
      showShareId: shareId
    };
  },

  extractShareIdFromLocation(location) {
    if (location.pathname.match(/\/shares\/.+/)){
      // try to get th share id from path
      let match = location.pathname.match(/\/shares\/(.+)/)
      if (match && match.length>1 && match[1] != 'new') {
        return match[1]
      }
    }
    return null
  },

  findShareById(shareId) {
    return this.props.items.find((item) => item.id === shareId)
  },

  componentWillReceiveProps(nextProps) {
    // load dependencies unless already loaded
    this.loadDependencies(nextProps)
  },

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  },

  loadDependencies(props) {
    if(!props.active) return;
    this.props.loadSharesOnce()
    this.props.loadShareNetworksOnce()
    this.props.loadAvailabilityZonesOnce()
    for(let share of props.items){
      this.props.loadShareRulesOnce(share.id)
    }
  },

  closeNew() {
    if(!this.state.showNew) return;
    this.setState({ showNew: false })
    this.props.history.replace('/shares')
  },

  openNew() {
    // return if already visible
    if(this.state.showNew) return;
    //if (this.state.showNew) return;
    this.setState({ showNew: true })
    // update url
    this.props.history.replace('/shares/new')
  },

  showShare(shareId) {
    if (!shareId) return
    this.setState({ showShareId: shareId })
    this.props.history.replace(`/shares/${shareId}`)
  },

  closeShow() {
    this.props.history.replace('/shares')
    this.setState({ showShareId: null })
  },

  shareNetwork(share) {
    for (let network of this.props.shareNetworks.items) {
      if (network.id==share.share_network_id) return network
    }
    return null
  },

  shareRules(share) {
    let rules = this.props.shareRules[share.id]
    if (!rules) return null;
    return rules
  },

  render() {
    let share = this.findShareById(this.state.showShareId)
    return (
      <div>

        { this.props.policy.isAllowed('shared_filesystem_storage:share_create') &&
          <div className='toolbar'>
            <button type="button" className="btn btn-primary" onClick={ (e) => {e.preventDefault(); this.openNew()} }>
              Create new
            </button>
            <NewShare show={this.state.showNew} onHide={this.closeNew}/>
          </div>
        }

        <ShowShare show={share!=null} onHide={this.closeShow} share={share}/>

        { this.props.policy.isAllowed('shared_filesystem_storage:share_list') ? (
          this.props.isFetching ? (
            <span className='spinner'></span>
          ) : (
            <table className='table shares'>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>
                    AZ
                    <i className='fa fa-fw fa-info-circle'
                      data-toggle="tooltip"
                      data-placement="top"
                      title="Availability Zone"></i>
                  </th>
                  <th>Protocol</th>
                  <th>Size</th>
                  <th>Status</th>
                  <th>Network</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                { this.props.items.length>0 ? (
                  this.props.items.map( (share, index) =>
                    <ShareItem key={index}
                      share={share}
                      shareNetwork={this.shareNetwork(share)}
                      shareRules={this.shareRules(share)}
                      handleShow={this.showShare}/>
                  )
                ) : (
                  <tr>
                    <td colSpan="6">No Shares found.</td>
                  </tr>
                )}
              </tbody>
            </table>
          )
        ) : (
          <span>You are not allowed to see this page</span>
        )}
      </div>
    )
  }
});

//export default withRouter(List);
export default List
