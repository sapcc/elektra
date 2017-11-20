import { connect } from  'react-redux';
import ShareList from '../../components/shares/list';
import {
  fetchSharesIfNeeded,
  fetchShareExportLocations,
  fetchAvailabilityZonesIfNeeded,
  deleteShare,
  reloadShare,
  filterShares,
  loadNext
} from '../../actions/shares'
import { fetchShareNetworksIfNeeded } from '../../actions/share_networks'
import { fetchShareRulesIfNeeded } from '../../actions/share_rules'

export default connect(
  ({shared_filesystem_storage: state}) => ({
    items: state.shares.items,
    isFetching: state.shares.isFetching,
    hasNext: state.shares.hasNext,
    shareNetworks: state.shareNetworks,
    shareRules: state.shareRules,
    availabilityZones: state.availabilityZones
  }),

  dispatch => ({
    loadSharesOnce: () => dispatch(fetchSharesIfNeeded()),
    loadShareNetworksOnce: () => dispatch(fetchShareNetworksIfNeeded()),
    loadShareRulesOnce: (shareId) => dispatch(fetchShareRulesIfNeeded(shareId)),
    loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    filterShares: (term) => dispatch(filterShares(term)),
    reloadShare: (shareId) => dispatch(reloadShare(shareId)),
    handleDelete: (shareId) => dispatch(deleteShare(shareId))
  })
)(ShareList);
