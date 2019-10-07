import { connect } from  'react-redux';
import { Scope } from '../../scope';
import AvailabilityZoneCategory from '../../components/availability_zones/category';

export default connect(
  (state, props) => ({
    category: state.limes.capacityData.categories[props.categoryName],
  }),
  dispatch => ({}),
)(AvailabilityZoneCategory);
