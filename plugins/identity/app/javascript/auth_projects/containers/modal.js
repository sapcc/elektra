import { connect } from  'react-redux'
import Modal from '../components/modal'
import {
  fetchAuthProjectsIfNeeded,
  toggleModal
} from '../actions'

export default connect(
  (state) => (
    {
      items: state.authProjects.items,
      showModal: state.authProjects.showModal,
      isFetching: state.authProjects.isFetching
    }
  ),

  dispatch => ({
    loadAuthProjectsOnce: () => dispatch(fetchAuthProjectsIfNeeded()),
    toggleModal: () => dispatch(toggleModal())
  })
)(Modal);
