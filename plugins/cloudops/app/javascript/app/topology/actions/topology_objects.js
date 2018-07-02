import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### OBJECTS #########################
const requestTopologyObjects= (objectId) => (
  {
    type: constants.REQUEST_TOPOLOGY_OBJECTS,
    objectId,
    requestedAt: Date.now()
  }
);

const requestTopologyObjectsFailure= (objectId) => (
  {
    objectId,
    type: constants.REQUEST_TOPOLOGY_OBJECTS_FAILURE
  }
);

const receiveTopologyObjects= (objectId,objectTopology) => (
  {
    type: constants.RECEIVE_TOPOLOGY_OBJECTS,
    receivedAt: Date.now(),
    objectTopology,
    objectId
  }
);

const fetchTopologyObjects = (objectId) => {
  return (dispatch) => {
    console.log('fetchTopologyObjects -> objectId',objectId)
    dispatch(requestTopologyObjects(objectId));

    ajaxHelper.get('/topology_objects', {params: {topology_object_id: objectId} })
      .then( (response) => {
        return dispatch(receiveTopologyObjects(objectId, response.data))
      })
      .catch( (error) => {
        dispatch(requestTopologyObjectsFailure(objectId));
      })
  }
}

export {
  fetchTopologyObjects
}
