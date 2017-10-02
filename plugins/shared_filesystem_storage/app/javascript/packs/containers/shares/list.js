import { connect } from  'react-redux';
import ShareList from '../../components/shares/list';
import { fetchSharesIfNeeded } from '../../actions/shares'

export default connect(
  state => ((pluginState) => ({
    /*activeTabUid: pluginState.activeTab.uid || getCurrentTabFromUrl() || 'shares'*/
    items: pluginState.shares.items,
    isFetching: pluginState.shares.isFetching
  }))(state.shared_filesystem_storage),

  dispatch => ({
    loadSharesOnce: () => dispatch(fetchSharesIfNeeded()),
    loadShareNetworksOnce: () => null,
    loadAvailabilityZonesOnce: () => null,
    loadShareRulesOnce: (shareId) => null
  })
)(ShareList);
