import { connect } from  'react-redux';
import ImageMembersModal from '../../components/os_images/image_members';
import { fetchImageMembersIfNeeded, submitNewImageMember, deleteImageMember} from '../../actions/image_members';

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

    if(state.members && image) {
      imageMembers = state.members.find((m,i) => m.image_id == image.id)
    }
    return { image, activeTab, imageMembers }
  },
  (dispatch) => ({
    loadMembersOnce: (imageId) => dispatch(fetchImageMembersIfNeeded(imageId)),
    handleSubmit: (values) => dispatch(submitNewImageMember(values)),
    handleDelete: (imageId,memberId) => dispatch(deleteImageMember(imageId,memberId))
  })
)(ImageMembersModal);
