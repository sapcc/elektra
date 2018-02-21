import { connect } from  'react-redux'
import Pagination from '../../components/shared/pagination'

export default connect(
  (state) => (
    {
      offset:       state.events.offset,
      limit:        state.events.limit,
      total:        state.events.total,
      currentPage:  state.events.currentPage
    }
  )
)(Pagination)
