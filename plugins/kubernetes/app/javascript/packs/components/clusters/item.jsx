import { Link } from 'react-router-dom';
import { policy } from 'policy';
// import { OverlayTrigger, Tooltip } from 'react-bootstrap';

// class RuleTooltip extends React.Component {
//   render() {
//     let al = this.props.rule.access_level
//     let tooltip = <Tooltip id='ruleTooltip'>
//       Access Level: {al=='ro' ? 'read only' : (al=='rw' ? 'read/write' : al)}
//     </Tooltip>;
//
//     return (
//       <OverlayTrigger
//         overlay={tooltip}
//         placement="top"
//         delayShow={300}
//         delayHide={150}
//       >
//         {this.props.children}
//       </OverlayTrigger>
//     );
//   }
// }


export default class ClusterItem extends React.Component {
  constructor(props){
    super(props);
    this.clusterState = this.clusterState.bind(this);

    // this.startPolling = this.startPolling.bind(this)
    // this.stopPolling = this.stopPolling.bind(this)
  }

  // componentWillReceiveProps(nextProps) {
  //   // stop polling if status has changed from creating to something else
  //   if (nextProps.share.status!='creating') this.stopPolling()
  //   nextProps.loadShareRulesOnce(nextProps.share.id)
  // }

  componentDidMount() {
    // if (this.props.share.status=='creating') this.startPolling()
    // this.props.loadShareRulesOnce(this.props.share.id)
  }

  // componentWillUnmount() {
  //   // stop polling on unmounting
  //   this.stopPolling()
  // }
  //
  // startPolling(){
  //   this.polling = setInterval(() =>
  //     this.props.reloadShare(this.props.share.id), 10000
  //   )
  // }
  //
  // stopPolling() {
  //   clearInterval(this.polling)
  // }

  clusterState() {
    let { cluster } = this.props;
    let spinner = null;
    if (!cluster.status.phase == 'Running') {
      spinner = <span className='spinner'></span>;
    }

    return (
      <span className='status-text'>{ ' | ' + cluster.status.phase } { spinner }</span>
    );
  }

  // ----------

  // startPolling() {
  //   @props.handlePollingStart(@props.cluster.name)
  //   clearInterval(@polling)
  //   @polling = setInterval((() => @props.reloadCluster(@props.cluster.name)), 10000)
  // }
  //
  // stopPolling() {
  //   @props.handlePollingStop(@props.cluster.name)
  //   clearInterval(@polling)
  // }
  //
  //
  // clusterReady(cluster) {
  //   cluster.status.phase == 'Running'
  // }
  //
  // nodePoolsReady(cluster) {
  //   // return ready only if all state values of all nodepools match the configured size
  //   ready = true
  //   for nodePool in cluster.status.nodePools
  //     ready = @nodePoolReady(nodePool, cluster)
  //   ready
  // }
  //
  //
  // nodePoolReady(nodePool, cluster) {
  //   ready = true
  //   specSize = @nodePoolSpecSize(cluster, nodePool.name)
  //   for k,v of nodePool
  //     unless k == 'name' || k == 'size'
  //       if v != specSize
  //         ready = false
  //         break
  //   ready
  // }
  //
  // // find spec size for pool with given name
  // nodePoolSpecSize(cluster, poolName) {
  //   pool = (cluster.spec.nodePools.filter (i) -> i.name is poolName)[0]
  //   pool.size
  // }


  render(){
    let { cluster, handleEditCluster, handleClusterDelete, handleGetCredentials, handleGetSetupInfo, handlePollingStart, handlePollingStop } = this.props;


    return(
      <div className='cluster'>
        <div className='cluster-info'>
          <h4>Cluster: { cluster.name } { this.clusterState() }</h4>
          <p className="info-text">{ cluster.status.message }</p>

          <h5>Nodepools:</h5>
          { cluster.spec.nodePools.map( (nodePool) =>
            <div className='nodepool-spec' key={ nodePool.name }>

              <h5 className='nodepool-title'>
                { nodePool.name }
              </h5>
              <div className='nodepool-info'>
                <div className='info-text'> { nodePool.flavor } </div>
                <div> size: { nodePool.size } </div>
              </div>
            </div>
          )}
        </div>
        <div className='main-control-buttons'>
          buttons
        </div>
      </div>





      //
      //
      // <tr className={ share.isDeleting ? 'updating' : ''}>
      //   <td>
      //     <Link to={`/shares/${share.id}/show`}>{share.name || share.id}</Link>
      //   </td>
      //   <td>{share.availability_zone}</td>
      //   <td>{share.share_proto}</td>
      //   <td>{(share.size || 0) + ' GB'}</td>
      //   <td>
      //     { share.status == 'creating' &&
      //       <span className='spinner'></span>
      //     }
      //     {share.status}
      //   </td>
      //   <td>
      //     { shareNetwork ? (
      //       <span>
      //         {shareNetwork.name}
      //         { shareNetwork.cidr &&
      //           <span className='info-text'>{" "+shareNetwork.cidr}</span>
      //         }
      //         { shareRules &&
      //           (
      //             shareRules.isFetching ? (
      //               <span className='spinner'></span>
      //             ) : (
      //               <span>
      //                 <br/>
      //                 { shareRules.items.map( (rule) =>
      //                   <RuleTooltip key={rule.id} rule={rule}>
      //                     <small
      //                       className={`${rule.access_level == 'rw' ? 'text-success' : 'text-info'}`}>
      //                       <i className={`fa fa-fw fa-${rule.access_level == 'rw' ? 'pencil-square' : 'eye'}`}/>
      //                       {rule.access_to}
      //                     </small>
      //                   </RuleTooltip>
      //
      //                 )}
      //               </span>
      //             )
      //           )}
      //       </span>) : (
      //       <span className='spinner'></span>
      //     )}
      //   </td>
      //   <td className="snug">
      //     { (policy.isAllowed("shared_filesystem_storage:share_delete") ||
      //        policy.isAllowed("shared_filesystem_storage:share_update")) &&
      //
      //       <div className='btn-group'>
      //         <button className="btn btn-default btn-sm dropdown-toggle" type="button" data-toggle="dropdown" aria-expanded="true">
      //           <i className='fa fa-cog'></i>
      //         </button>
      //         <ul className='dropdown-menu dropdown-menu-right' role="menu">
      //           { policy.isAllowed("shared_filesystem_storage:share_delete") &&
      //             <li><a href='#' onClick={ (e) => { e.preventDefault(); handleDelete(share.id) } }>Delete</a></li>
      //           }
      //           { policy.isAllowed("shared_filesystem_storage:share_update") &&
      //             <li>
      //               <Link to={`/shares/${share.id}/edit`}>Edit</Link>
      //             </li>
      //           }
      //           { policy.isAllowed("shared_filesystem_storage:share_update") && share.status=='available' &&
      //             <li>
      //               <Link to={`/shares/${share.id}/snapshots/new`}>Create Snapshot</Link>
      //             </li>
      //           }
      //           { policy.isAllowed("shared_filesystem_storage:share_update") && share.status=='available' &&
      //             <li>
      //               <Link to={`/shares/${share.id}/access-control`}>Access Control</Link>
      //             </li>
      //           }
      //         </ul>
      //       </div>
      //     }
      //   </td>
      // </tr>
    )
  }
}
