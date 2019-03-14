import { connect } from  'react-redux';
import { listSubscopes } from '../../actions/limes';
import DetailsModal from '../../components/details/modal';

export default connect(
  (state, props) => {
    const { categoryName, resourceName } = props.match.params;
    const category = state.limes.categories[categoryName];
    const resource = category.resources.find(res => res.name == resourceName);
    return {
      metadata: state.limes.metadata,
      categoryName, resourceName,
      category, resource,
    };
  },
  dispatch => ({
    listSubscopes: (...args) => dispatch(listSubscopes(...args)),
  }),
)(DetailsModal);
