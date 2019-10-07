import { connect } from  'react-redux';
import { Scope } from '../../scope';
import AvailabilityZoneOverview from '../../components/availability_zones/overview';

export default connect(
  (state, props) => {
    const data = state.limes.capacityData;
    return {
      isFetching: data.isFetching || data.receivedAt == null,
      overview:   data.overview,
    };
  },
  dispatch => ({}),
)(AvailabilityZoneOverview);
