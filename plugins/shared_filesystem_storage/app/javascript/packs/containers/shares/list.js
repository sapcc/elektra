import { connect } from  'react-redux';
import ShareList from '../../components/shares/list';
import {
  fetchSharesIfNeeded,
  fetchShareExportLocations,
  fetchAvailabilityZonesIfNeeded,
  deleteShare,
  reloadShare,
  filterShares
} from '../../actions/shares'
import { fetchShareNetworksIfNeeded } from '../../actions/share_networks'
import { fetchShareRulesIfNeeded } from '../../actions/share_rules'

export default connect(
  state => ((pluginState) => ({
    items: pluginState.shares.items,
    isFetching: pluginState.shares.isFetching,
    shareNetworks: pluginState.shareNetworks,
    shareRules: pluginState.shareRules,
    availabilityZones: pluginState.availabilityZones
  }))(state.shared_filesystem_storage),

  dispatch => ({
    loadSharesOnce: () => dispatch(fetchSharesIfNeeded()),
    loadShareNetworksOnce: () => dispatch(fetchShareNetworksIfNeeded()),
    loadShareRulesOnce: (shareId) => dispatch(fetchShareRulesIfNeeded(shareId)),
    loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
    filterShares: (term) => dispatch(filterShares(term)),
    reloadShare: (shareId) => dispatch(reloadShare(shareId)),
    handleDelete: (shareId) => dispatch(deleteShare(shareId))
  })
)(ShareList);
