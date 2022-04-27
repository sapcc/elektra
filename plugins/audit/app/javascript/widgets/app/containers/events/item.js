import { connect } from  'react-redux'
import Event from '../../components/events/item'
import { toggleEventDetails } from '../../actions/events'

export default connect(
  (state) => ({}),
  (dispatch) => (
    {toggleDetails: (event) => dispatch(toggleEventDetails(event))}
  )
)(Event)
