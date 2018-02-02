import { connect } from  'react-redux';
import ClusterList from '../../components/clusters/list';
// import {
//   fetchSharesIfNeeded,
//   fetchShareExportLocations,
// } from '../../actions/shares'
// import { fetchShareNetworksIfNeeded } from '../../actions/share_networks'
// import { fetchShareRulesIfNeeded } from '../../actions/share_rules'

export default connect(
  ({kubernetes: state}) => ({
    items: state.clusters.items,
    isFetching: state.clusters.isFetching
  }),

  dispatch => ({
    // loadSharesOnce: () => dispatch(fetchSharesIfNeeded()),
    // loadShareRulesOnce: (shareId) => dispatch(fetchShareRulesIfNeeded(shareId))
  })
)(ClusterList);
