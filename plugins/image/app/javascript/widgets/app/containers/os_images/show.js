import { connect } from "react-redux"
import ShowOsImageModal from "../../components/os_images/show"

import imageActions from "../../actions/os_images"
const availableImageActions = imageActions("available")
const suggestedImageActions = imageActions("suggested")

export default connect(
  (state, ownProps) => {
    let image
    let activeTab
    let match = ownProps.match
    let imageId = match.params.id

    if (match && match.params && match.params.activeTab && match.params.id) {
      activeTab = match.params.activeTab
      let images = state[match.params.activeTab].items
      if (images) image = images.find((item) => item.id == match.params.id)
    }
    return { image, activeTab, imageId }
  },
  (dispatch, ownProps) => {
    const imageId = ownProps?.match?.params?.id
    const activeTab = ownProps?.match?.params?.activeTab
    let actions =
      activeTab === "available" ? availableImageActions : suggestedImageActions

    // reloadImage function should be used to load image on show dialog if it
    // is not in the images list yet.
    return {
      loadImage: () => imageId && dispatch(actions.reloadOsImage(imageId)),
    }
  }
)(ShowOsImageModal)
