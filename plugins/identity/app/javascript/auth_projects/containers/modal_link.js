import { connect } from  'react-redux'
import ModalLink from '../components/modal_link'
import { toggleModal } from '../actions'

export default connect(
  (state) => (
    {
      showModal: state.authProjects.showModal
    }
  ),

  dispatch => ({
    toggleModal: () => dispatch(toggleModal())
  })
)(ModalLink);
