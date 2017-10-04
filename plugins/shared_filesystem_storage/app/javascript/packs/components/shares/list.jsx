import { withRouter, Route } from 'react-router-dom'

import NewShare from './new'
import ShowShare from './show'
import ShareItem from './item'

const List = React.createClass({
  getInitialState() {
    return {
      showNew: false, //boolean, indicates whether the new dialog is visible or not
      showShare: null //object, if set a modal show window is visible
    };
  },

  componentWillReceiveProps(nextProps) {
    // load dependencies unless already loaded
    this.loadDependencies(nextProps)
  },

  componentWillUpdate() {
    // component did receive new props or state has changed ->
    // check url path and render corresponding overlays if needed
    //this.checkRoutes()
  },

  componentDidMount() {
    console.log('Shares list did mount')
    // check url path and render corresponding overlays if needed
    //this.checkRoutes()
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  },

  checkRoutes() {
    if (this.props.location.pathname=='/shares/new'){
      this.setState({showNew: true})
    } else if (this.props.location.pathname.match(/\/shares\/.+/)){
      // try to get th share id from path
      let match = this.props.location.pathname.match(/\/shares\/(.+)/)
      if (match && match.length>0) {
        // show share dialog if found
        let share = this.props.items.find((item) => { return item.id == match[1] })
        this.setState({showShare: share})
      }
    }
  },

  loadDependencies(props) {
    this.props.loadSharesOnce()
    this.props.loadShareNetworksOnce()
    this.props.loadAvailabilityZonesOnce()
    for(let share of props.items){
      this.props.loadShareRulesOnce(share.id)
    }
  },

  closeNew() {
    this.setState({ showNew: false })
    this.props.history.push('/shares')
  },

  openNew() {
    // return if already visible
    console.log(this.state.showNew)
    if (this.state.showNew) return;
    this.setState({ showNew: true })
    //this.props.history.replace('/shares/new')
  },

  showShare(share) {
    // return if already visible
    if (this.state.showShare) return;
    if (!share) return
    // this line of code may lead to concurrency problem
    // if so move it to show in componentDidMount Callback!
    //this.props.loadExportLocations(share.id)
    this.setState({ showShare: share })
    //this.props.history.replace(`/shares/${share.id}`)
  },

  closeShow() {
    this.setState({ showShare: null })
    //this.props.history.replace('/shares')
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
    return (
      <div>

        { this.props.policy.isAllowed('shared_filesystem_storage:share_create') &&
          <div className='toolbar'>
            <button type="button" className="btn btn-primary" onClick={ (e) => {e.preventDefault(); this.openNew()} }>
              Create new
            </button>
            <Route path="/shares/new" render={ () => <NewShare show={true} onHide={this.closeNew}/>} />
          </div>
        }

        <ShowShare show={this.state.showShare!=null}
          onHide={this.closeShow}
          share={this.state.showShare}/>

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

export default withRouter(List);
