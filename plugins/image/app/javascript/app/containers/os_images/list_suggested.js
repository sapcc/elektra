import { connect } from  'react-redux';
import OsImageList from '../../components/os_images/list';

import imageActions from '../../actions/os_images'
const actions = imageActions('suggested')

export default connect(
  (state, ownProps) => ({
    activeTab: 'suggested',
    items: state.suggested.items,
    isFetching: state.suggested.isFetching,
    hasNext: state.suggested.hasNext,
    searchTerm: state.suggested.searchTerm
  }),

  dispatch => ({
    loadOsImagesOnce: () => dispatch(actions.fetchOsImagesIfNeeded()),
    loadNext: () => dispatch(actions.loadNext()),
    searchOsImages: (term) => dispatch(actions.searchOsImages(term)),
    reloadOsImage: (osImageId) => dispatch(actions.reloadOsImage(osImageId)),
    handleDelete: (osImageId) => dispatch(actions.deleteOsImage(osImageId))
  })
)(OsImageList);
