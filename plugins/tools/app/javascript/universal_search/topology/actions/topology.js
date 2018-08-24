import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### OBJECTS #########################
const removeLeaves= (objectId) => (
  {
    type: constants.REMOVE_LEAVES,
    objectId
  }
);

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

const receiveTopologyObjects= (parentId,objects) => (
  {
    type: constants.RECEIVE_TOPOLOGY_OBJECTS,
    receivedAt: Date.now(),
    objects,
    parentId
  }
);

const fetchTopologyObjects = (objectId) => {
  return (dispatch,getState) => {

    // get current objects from state
    const objects = getState()['topology']['objects']

    Promise.resolve(objects[objectId])
      .then(parent => {
        if (parent && parent.id && parent.receivedAt) return {data: parent}
        // start request
        dispatch(requestTopologyObjects(objectId));
        // load parent object from api
        return ajaxHelper.get(`/cache/${objectId}`)
      })
      .then(response => {
        let parent = response.data
        return Promise.all([
          parent,
          ajaxHelper.get('/cache/related-objects', {params: {id: parent.id}})
        ]);
      })
      .then(results => {
        let parent = results[0]
        let objects = results[1].data
        objects.unshift(parent)
        return dispatch(receiveTopologyObjects(parent.id, objects))
      })
      .catch( (error) => {
        console.log(error, error.message)
        return dispatch(requestTopologyObjectsFailure(objectId));
      })
  }
}

const reset = () => (
  {
    type: constants.RESET_TOPOLOGY_STATE
  }
)

export {
  fetchTopologyObjects,
  removeLeaves,
  reset
}
