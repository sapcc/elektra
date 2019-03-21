import { connect } from  'react-redux';
import { fetchData, listClusters, listSubscopes, setQuota } from '../../actions/limes';
import DetailsModal from '../../components/details/modal';

export default connect(
  (state, props) => {
    const { categoryName, resourceName } = props.match.params;
    const category = state.limes.categories[categoryName];
    const resource = category.resources.find(res => res.name == resourceName);
    return {
      isFetching: state.limes.isFetching,
      metadata:   state.limes.metadata,
      categoryName, resourceName,
      category, resource,
    };
  },
  dispatch => ({
    fetchData:     (...args) => dispatch(fetchData(...args)),
    listClusters:  (...args) => dispatch(listClusters(...args)),
    listSubscopes: (...args) => dispatch(listSubscopes(...args)),
    setQuota:      (...args) => dispatch(setQuota(...args)),
  }),
)(DetailsModal);
