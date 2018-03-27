import { connect } from  'react-redux';
import OsImageList from '../../components/os_images/list';

import imageActions from '../../actions/os_images'
const actions = imageActions('available')

export default connect(
  (state, ownProps) => ({
    activeTab: 'available',
    items: state.available.items,
    isFetching: state.available.isFetching,
    hasNext: state.available.hasNext,
    searchTerm: state.available.searchTerm
  }),

  dispatch => ({
    loadOsImagesOnce: () => dispatch(actions.fetchOsImagesIfNeeded()),
    loadNext: () => dispatch(actions.loadNext()),
    searchOsImages: (term) => dispatch(actions.searchOsImages(term)),
    reloadOsImage: (osImageId) => dispatch(actions.reloadOsImage(osImageId)),
    handleDelete: (osImageId) => dispatch(actions.deleteOsImage(osImageId))
  })
)(OsImageList);
