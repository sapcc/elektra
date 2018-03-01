import { connect } from  'react-redux'
import Page from '../../components/shared/page'
import { paginate } from '../../actions/events'

export default connect(
  (state) => (
    { currentPage: state.events.currentPage }
  ),
  (dispatch) => (
    { handlePageChange: (page) => dispatch(paginate(page)) }
  )
)(Page)
