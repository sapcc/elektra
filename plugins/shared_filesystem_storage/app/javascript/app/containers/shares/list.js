import { connect } from  'react-redux';
import ShareList from '../../components/shares/list';
import {
  fetchSharesIfNeeded,
  fetchShareExportLocations,
  fetchAvailabilityZonesIfNeeded,
  deleteShare,
  forceDeleteShare,
  reloadShare,
  searchShares,
  loadNext
} from '../../actions/shares'
import { fetchShareNetworksIfNeeded } from '../../actions/share_networks'
import { fetchShareRulesIfNeeded } from '../../actions/share_rules'
import { fetchShareUtilizationIfNeeded } from '../../actions/maia';

export default connect(
  (state) => ({
    items: state.shares.items,
    isFetching: state.shares.isFetching,
    hasNext: state.shares.hasNext,
    searchTerm: state.shares.searchTerm,
    shareNetworks: state.shareNetworks,
    shareRules: state.shareRules,
    availabilityZones: state.availabilityZones,
    shareUtilization: state.maia.utilization,
  }),

  dispatch => ({
    loadSharesOnce: () => dispatch(fetchSharesIfNeeded()),
    loadShareNetworksOnce: () => dispatch(fetchShareNetworksIfNeeded()),
    loadShareRulesOnce: (shareId) => dispatch(fetchShareRulesIfNeeded(shareId)),
    loadAvailabilityZonesOnce: () => dispatch(fetchAvailabilityZonesIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    searchShares: (term) => dispatch(searchShares(term)),
    reloadShare: (shareId) => dispatch(reloadShare(shareId)),
    handleDelete: (shareId) => dispatch(deleteShare(shareId)),
    handleForceDelete: (shareId) => dispatch(forceDeleteShare(shareId)),
    loadShareUtilizationOnce: () => dispatch(fetchShareUtilizationIfNeeded()),
  }),
)(ShareList);
