import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice as showNotice, addError as showError } from 'lib/flashes';
import { ErrorsList } from 'lib/elektra-form/components/errors_list';

//################### OBJECTS #########################
const requestObjects= () => (
  {
    type: constants.REQUEST_OBJECTS,
    requestedAt: Date.now()
  }
);

const requestObjectsFailure= () => (
  {
    type: constants.REQUEST_OBJECTS_FAILURE
  }
);

const receiveObjects= ({objects,currentPage,hasNext,total}) => (
  {
    type: constants.RECEIVE_OBJECTS,
    receivedAt: Date.now(),
    objects,
    currentPage,
    hasNext,
    total
  }
);

const fetchObjects = (options) => {
  const params = {
    page: options.page || 1,
    type: options.objectType,
    term: options.term
  }
  return ajaxHelper.get('/objects', {params: params})
}

const searchObjects= ({term,objectType}) =>
  function(dispatch) {
    dispatch(requestObjects());
    fetchObjects({term,objectType}).then( (response) => {
      return dispatch(receiveObjects({
        objects: response.data.items,
        currentPage: 1,
        total: response.data.total,
        hasNext: response.data.hasNext
      }));
    })
    .catch( (error) => {
      dispatch(requestObjectsFailure());
      showError(`Could not load objects (${error.message})`)
    });
  }

const loadNextObjects= ({term,objectType}) =>
  function(dispatch, getState) {
    const {objects} = getState()['search'];
    const page = objects.currentPage + 1

    if(!objects.isFetching && objects.hasNext) {
      dispatch(requestObjects());
      fetchObjects({term,objectType,page}).then( (response) => {
        return dispatch(receiveObjects({
          objects: response.data.items,
          currentPage: page,
          total: response.data.total,
          hasNext: response.data.hasNext
        }));
      })
      .catch( (error) => {
        dispatch(requestObjectsFailure());
        showError(`Could not load objects (${error.message})`)
      });
    }
  }
;

const receiveObject= (json) => (
  {
    type: constants.RECEIVE_OBJECT,
    json
  }
);

const fetchObject = (id) =>
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.get(`/objects/${id}`).then( response => {
        dispatch(receiveObject(response.data))
      }).catch( error => handleErrors(error.message))
    )
;

export {
  searchObjects,
  loadNextObjects,
  fetchObject
}
