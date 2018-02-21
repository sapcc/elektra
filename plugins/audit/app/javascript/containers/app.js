import { connect } from  'react-redux'
import App from '../components/app'
import { fetchEvents } from '../actions/events'

export default connect(
  (state) =>(
    { events: state.events.items, isFetching: state.isFetching }
  ),
  (dispatch) => (
    { loadEvents: (offset) => dispatch(fetchEvents(offset)) }
  )
)(App)
