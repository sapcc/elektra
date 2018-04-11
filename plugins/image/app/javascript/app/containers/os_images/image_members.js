import { connect } from  'react-redux';
import ImageMembersModal from '../../components/os_images/image_members';
import { fetchImageMembersIfNeeded, resetImageMembers, submitNewImageMember, deleteImageMember} from '../../actions/image_members';

export default connect(
  (state,ownProps ) => {
    let image;
    let activeTab;
    let imageMembers;

    const match = ownProps.match

    if (match && match.params && match.params.activeTab && match.params.id) {
      activeTab = match.params.activeTab
      let images = state[match.params.activeTab].items
      if (images) image = images.find(item => item.id == match.params.id)
    }

    if(image && state.imageMembers && state.imageMembers[image.id] ) {
      imageMembers = state.imageMembers[image.id]
    }
    return { image, activeTab, imageMembers }
  },
  (dispatch) => ({
    loadMembersOnce: (imageId) => dispatch(fetchImageMembersIfNeeded(imageId)),
    resetImageMembers: (imageId) => dispatch(resetImageMembers(imageId)),
    handleSubmit: (imageId,memberId) => dispatch(submitNewImageMember(imageId, memberId)),
    handleDelete: (imageId,memberId) => dispatch(deleteImageMember(imageId,memberId))
  })
)(ImageMembersModal);
