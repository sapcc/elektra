import { connect } from  'react-redux'
import List from '../components/list'
import {
  fetchAuthProjectsIfNeeded
} from '../actions'

export default connect(
  (state) => (
    {
      items: state.authProjects.items,
      isFetching: state.authProjects.isFetching
    }
  ),

  dispatch => ({
    loadAuthProjectsOnce: () => dispatch(fetchAuthProjectsIfNeeded())
  })
)(List);
