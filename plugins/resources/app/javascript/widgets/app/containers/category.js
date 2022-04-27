import { connect } from  'react-redux';
import Category from '../components/category';

export default connect(
  (state, props) => ({
    metadata: state.limes.metadata,
    category: state.limes.categories[props.categoryName],
  }),
  dispatch => ({}),
)(Category);
