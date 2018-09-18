import { connect } from  'react-redux';
import VolumeList from '../../components/volumes/list';

import {fetchVolumesIfNeeded, loadNext, searchVolumes} from '../../actions/volumes'

export default connect(
  (state) => ({
    volumes: state.volumes
  }),
  dispatch => ({
    loadVolumesOnce: () => dispatch(fetchVolumesIfNeeded()),
    loadNext: () => dispatch(loadNext()),
    search: (term) => dispatch(searchVolumes(term)),
  })
)(VolumeList);
