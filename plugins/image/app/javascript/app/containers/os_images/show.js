import { connect } from  'react-redux';
import ShowOsImageModal from '../../components/os_images/show';

export default connect(
  (state,ownProps ) => {
    let image;
    let activeTab;
    let match = ownProps.match

    if (match && match.params && match.params.activeTab && match.params.id) {
      activeTab = match.params.activeTab
      let images = state[match.params.activeTab].items
      if (images) image = images.find(item => item.id == match.params.id)
    }
    return { image, activeTab }
  }
)(ShowOsImageModal);
