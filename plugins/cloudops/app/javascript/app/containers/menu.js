import { connect } from  'react-redux';
import Menu from '../components/menu';

import {
  searchObjects
} from '../search/actions/objects'

export default connect(
  (state) => ({
    objects: state.search.objects
  }),
  dispatch => ({
    search: (searchOptions) => dispatch(searchObjects(searchOptions))
  })
)(Menu);
