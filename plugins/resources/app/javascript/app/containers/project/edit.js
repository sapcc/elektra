import { connect } from  'react-redux';
import ProjectEditModal from '../../components/project/edit';

export default connect(
  (state, props) => ({
    metadata: state.project.metadata,
    category: state.project.categories[props.match.params.categoryName],
    categoryName: props.match.params.categoryName,
  }),
  dispatch => ({
  }),
)(ProjectEditModal);
