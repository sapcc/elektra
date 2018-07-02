import { connect } from  'react-redux';
import ObjectTopology from '../components/object_topology';
import { fetchTopologyObjects } from '../actions/topology_objects'

export default connect(
  (state,ownProps ) => {
    return { topologyObjects: state.topology.topology_objects }
  },
  dispatch => ({
    loadSubtree: (objectId) => dispatch(fetchTopologyObjects(objectId))
  })
)(ObjectTopology);
