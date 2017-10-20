import { withRouter, Route, Link } from 'react-router-dom';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import { CSSTransition, TransitionGroup } from 'react-transition-group';

import ShareItem from './item';

const FadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={500} classNames="css-transition-fade">
    {children}
  </CSSTransition>
);

const noShareNetworksInfo = (
  <Popover id="popover-no-share-networks" title="No Share Network found">
    Please <Link to="/share-networks">create a Share Network</Link> first.
  </Popover>
);

const loadingShareNetworksInfo = (
  <Popover id="popover-loading-share-networks" title="Loading Share Networks ...">
    Please wait.
  </Popover>
);

const List = React.createClass({
  findShareById(shareId) {
    if (!this.props.items) return null;
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

  toolbar() {
    if (!this.props.policy.isAllowed('shared_filesystem_storage:share_create')) return null;

    let { shareNetworks: {items: shareNetworkItems, isFetching: fetchingShareNetworks} } = this.props
    let hasShareNetworks = shareNetworkItems && shareNetworkItems.length>0

    return (
      <div className='toolbar'>
        <TransitionGroup>
          { fetchingShareNetworks ? (
            <FadeTransition>
              <OverlayTrigger trigger="click" placement="top" rootClose overlay={loadingShareNetworksInfo}>
                <span className="pull-right"><a href="#"><span className="spinner"></span></a></span>
              </OverlayTrigger>
            </FadeTransition>
          ) : ( !hasShareNetworks &&
            <FadeTransition>
              <span className="pull-right">
                <OverlayTrigger trigger="click" placement="top" rootClose overlay={noShareNetworksInfo}>
                  <a className='text-warning' href='#'>
                    <i className='fa fa-fw fa-exclamation-triangle fa-2'></i>
                  </a>
                </OverlayTrigger>
              </span>
            </FadeTransition>
          )}
        </TransitionGroup>

        <Link to='/shares/new' className='btn btn-primary'>Create new</Link>
      </div>
    )
  },

  renderTable() {
    let { items } = this.props
    return (
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
          { items && items.length>0 ? (
            items.map( (share, index) =>
              <ShareItem key={index}
                share={share}
                shareNetwork={this.shareNetwork(share)}
                shareRules={this.shareRules(share)}
                handleShow={this.showShare}
                handleEdit={this.editShare}
                handleDelete={this.props.handleDelete}/>)
            ) : (
              <tr>
                <td colSpan="6">No Shares found.</td>
              </tr>
            )
          }
        </tbody>
      </table>
    )
  },

  render() {
    return (
      <div>
        { this.toolbar() }
        { !this.props.policy.isAllowed('shared_filesystem_storage:share_list') ? (
          <span>You are not allowed to see this page</span>) : (
          this.props.isFetching ? <span className='spinner'></span> : this.renderTable()
        )}
      </div>
    )
  }
});

//export default withRouter(List);
export default List
