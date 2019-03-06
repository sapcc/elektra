import { connect } from  'react-redux';
import ProjectCategory from '../../components/project/category';

export default connect(
  (state, props) => ({
    metadata: state.limes.metadata,
    category: state.limes.categories[props.categoryName],
  }),
  dispatch => ({}),
)(ProjectCategory);
