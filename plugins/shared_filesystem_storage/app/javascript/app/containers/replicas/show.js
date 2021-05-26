import { connect } from "react-redux"
import Show from "../../components/replicas/show"

export default connect(
  (state, ownProps) => {
    let replica
    if (
      ownProps.match &&
      ownProps.match.params &&
      ownProps.match.params.id &&
      state.replicas.items
    ) {
      replica = state.replicas.items.find(
        (i) => i.id == ownProps.match.params.id
      )
    }

    return { replica }
  },
  (dispatch) => ({})
)(Show)
