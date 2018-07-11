import { connect } from  'react-redux';
import Application from '../components/application';

import { fetchNetworkUsageStatsIfNeeded } from '../actions/network_stats';

export default connect(
  (state) => {
    return {
      networkUsageStats: state.network_usage_stats
    }
  },

  dispatch => ({
    loadNetworkUsageStatsOnce: () => dispatch(fetchNetworkUsageStatsIfNeeded())
  })
)(Application);
