import { connect } from "react-redux"
import ShowItemModal from "../components/show"
import { fetchObject } from "../actions/objects"

export default connect(
  (state, ownProps) => {
    let item
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      let objects = state.search.objects.items
      if (objects) item = objects.find((item) => item.id == match.params.id)
    }

    let project
    // console.log(":::::::::::::::::::::::",state.search.projects)
    if (item && item.project_id) {
      if (state.search.projects.items)
        project = state.search.projects.items.find(
          (i) => i.id === item.project_id
        )
    }

    return { item, project }
  },
  (dispatch) => ({
    load: (id) => dispatch(fetchObject(id)),
  })
)(ShowItemModal)
