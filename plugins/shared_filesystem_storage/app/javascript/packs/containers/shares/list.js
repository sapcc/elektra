import { connect } from  'react-redux';
import ShareList from '../../components/shares/list';
import {
  fetchSharesIfNeeded,
  fetchShareExportLocations
} from '../../actions/shares'
import { fetchShareNetworksIfNeeded } from '../../actions/share_networks'
import { fetchShareRulesIfNeeded } from '../../actions/share_rules'

export default connect(
  state => ((pluginState) => ({
    /*activeTabUid: pluginState.activeTab.uid || getCurrentTabFromUrl() || 'shares'*/
    items: pluginState.shares.items,
    isFetching: pluginState.shares.isFetching,
    shareNetworks: pluginState.shareNetworks,
    shareRules: pluginState.shareRules
  }))(state.shared_filesystem_storage),

  dispatch => ({
    loadSharesOnce: () => dispatch(fetchSharesIfNeeded()),
    loadShareNetworksOnce: () => dispatch(fetchShareNetworksIfNeeded()),
    loadShareRulesOnce: (shareId) => dispatch(fetchShareRulesIfNeeded(shareId)),
    loadExportLocations: (shareId) => dispatch(fetchShareExportLocations(shareId)),
    loadAvailabilityZonesOnce: () => null,
  })
)(ShareList);
