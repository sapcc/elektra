import { connect } from  'react-redux';
import Projects from '../../components/project_role_assignments/projects';

import { searchProjects, loadNextProjects } from '../../actions/projects'

export default connect(
  (state) => ({
    projects: state.search.projects
  }),
  dispatch => ({
    search: (searchOptions) => dispatch(searchProjects(searchOptions)),
    loadNext:(searchOptions) => dispatch(loadNextProjects(searchOptions))
  })
)(Projects);
