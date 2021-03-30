import { connect } from  'react-redux';
import { Scope } from '../../scope';
import AvailabilityZoneCategory from '../../components/availability_zones/category';

export default connect(
  (state, props) => {
    const data = state.limes.capacityData;

    return {
      category:          data.categories[props.categoryName],
      availabilityZones: data.availabilityZones,
      projectShards:     props.projectShards,
      shardingEnabled:   props.shardingEnabled,
      projectScope: props.projectScope,
    };
  },
  dispatch => ({}),
)(AvailabilityZoneCategory);
