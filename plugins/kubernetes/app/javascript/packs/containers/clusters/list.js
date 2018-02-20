import { connect } from  'react-redux';
import ClusterList from '../../components/clusters/list';
import {
  fetchClusters
} from '../../actions/clusters'
// import { fetchShareNetworksIfNeeded } from '../../actions/share_networks'
// import { fetchShareRulesIfNeeded } from '../../actions/share_rules'

export default connect(
  ({kubernetes: state}) => ({
    clusters:    state.clusters.items,
    isFetching:  state.clusters.isFetching,
    error:       state.clusters.error,
    flashError:  state.clusters.flashError
  }),

  dispatch => ({
    loadClusters: () => dispatch(fetchClusters()),
    // loadShareRulesOnce: (shareId) => dispatch(fetchShareRulesIfNeeded(shareId))
  })
)(ClusterList);
