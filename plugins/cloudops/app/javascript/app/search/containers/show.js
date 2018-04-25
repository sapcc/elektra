import { connect } from  'react-redux';
import ShowItemModal from '../components/show';
import { fetchObject } from '../actions/objects'

export default connect(
  (state,ownProps ) => {
    let item;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      let objects = state.search.objects.items
      if (objects) item = objects.find(item => item.id==match.params.id)
    }

    return { item }
  },
  dispatch => ({
    load: (id) => dispatch(fetchObject(id))
  })
)(ShowItemModal);
