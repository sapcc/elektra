import { connect } from  'react-redux';
import Home from '../components/home';

import { searchProjects, loadNextProjects } from '../actions/projects'

export default connect(
  (state) => ({
    projects: state.role_assignments.projects
  }),
  dispatch => ({
    search: (searchOptions) => dispatch(searchProjects(searchOptions)),
    loadNext:(searchOptions) => dispatch(loadNextProjects(searchOptions))
  })
)(Home);
