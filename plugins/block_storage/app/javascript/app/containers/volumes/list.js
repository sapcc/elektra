import { connect } from  'react-redux';
import VolumeList from '../../components/volumes/list';

import {
  fetchVolumesIfNeeded,
  fetchVolumes,
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
    fetchVolumes: (params={}) => dispatch(fetchVolumes(params)),
    loadVolumesOnce: () => dispatch(fetchVolumesIfNeeded()),
    reloadVolume: (id) => dispatch(fetchVolume(id)),
    deleteVolume: (id) => dispatch(deleteVolume(id)),
    forceDeleteVolume: (id) => dispatch(forceDeleteVolume(id)),
    detachVolume: (id, attachmentId) => dispatch(detachVolume(id, attachmentId)),
    listenToVolumes: () => dispatch(listenToVolumes())
  })
)(VolumeList);
