import { connect } from  'react-redux';
import ProjectCategory from '../../components/project/category';

export default connect(
  (state, props) => ({
    metadata: state.project.metadata,
    category: state.project.categories[props.categoryName],
  }),
  dispatch => ({}),
)(ProjectCategory);
