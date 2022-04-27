import { connect } from  'react-redux';
import Menu from '../components/menu';
import { withRouter } from 'react-router-dom';

import {
  searchObjects
} from '../../../../../tools/app/javascript/universal_search/search/actions/objects'

export default withRouter(connect(
  (state) => ({
    objects: state.search.objects
  }),
  dispatch => ({
    search: (searchOptions) => dispatch(searchObjects(searchOptions))
  })
)(Menu));
