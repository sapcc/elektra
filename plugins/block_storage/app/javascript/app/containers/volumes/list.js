import { connect } from  'react-redux';
import VolumeList from '../../components/volumes/list';

import {
  fetchVolumesIfNeeded,
  loadNext,
  searchVolumes,
  fetchVolume,
  deleteVolume,
  forceDeleteVolume,
  detachVolume,
  listenToVolumes
} from '../../actions/volumes'

export default connect(
  (state) => ({
    volumes: state.volumes
  }),
  dispatch => ({
    loadVolumesOnce: () => dispatch(fetchVolumesIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    search: (term) => dispatch(searchVolumes(term)),
    reloadVolume: (id) => dispatch(fetchVolume(id)),
    deleteVolume: (id) => dispatch(deleteVolume(id)),
    forceDeleteVolume: (id) => dispatch(forceDeleteVolume(id)),
    detachVolume: (id, attachmentId) => dispatch(detachVolume(id, attachmentId)),
    listenToVolumes: () => dispatch(listenToVolumes())
  })
)(VolumeList);
