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

const updateSearchParams= ({term,objectType}) => (
  {
    type: constants.UPDATE_SEARCH_PARAMS,
    term,
    objectType
  }
)

const requestObjectsFailure= () => (
  {
    type: constants.REQUEST_OBJECTS_FAILURE
  }
);

const receiveObjects= ({objects,currentPage,hasNext,total,replace}) => (
  {
    type: constants.RECEIVE_OBJECTS,
    receivedAt: Date.now(),
    objects,
    currentPage,
    hasNext,
    total,
    replace
  }
);

const fetchObjects = (options) => {
  const params = {
    page: options.page || 1,
    type: options.objectType,
    term: options.term
  }
  return ajaxHelper.get('/cache', {params: params})
}

const loadObjects= ({term, objectType, page=1, replace=false}) => {
  return (dispatch) => {
    dispatch(requestObjects());

    fetchObjects({term, objectType, page}).then( (response) => {
      return dispatch(receiveObjects({
        objects: response.data.items,
        currentPage: page,
        total: response.data.total,
        hasNext: response.data.hasNext,
        replace
      }));
    })
    .catch( (error) => {
      dispatch(requestObjectsFailure());
      showError(`Could not load objects (${error.message})`)
    });
  }
};

const loadNextObjects= () =>
  function(dispatch, getState) {
    const {objects} = getState()['search'];
    const page = objects.currentPage + 1
    const term = objects.searchTerm
    const objectType = objects.searchType

    if(!objects.isFetching && objects.hasNext) {
      dispatch(loadObjects({term, objectType, page}))
    }
  }
;

const loadObjectsPage= (page) =>
  function(dispatch, getState) {
    const {objects} = getState()['search'];
    const term = objects.searchTerm
    const objectType = objects.searchType

    if(!objects.isFetching) {
      dispatch(loadObjects({term, objectType, page, replace: true}))
    }
  }
;

let searchTimer = null
const searchObjects = ({term,objectType}) =>
  (dispatch,getState) => {
    if(searchTimer) clearTimeout(searchTimer)
    dispatch(updateSearchParams({term,objectType}))
    
    const timeout = objectType==null ? 500 : 0
    searchTimer = setTimeout(() => {
      const lastTimer = searchTimer

      const {objects} = getState()['search'];
      term = objects.searchTerm
      objectType = objects.searchType
      dispatch(loadObjects({term, objectType, page: 1}))
    }
    , timeout
    )
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
      ajaxHelper.get(`/cache/${id}`).then( response => {
        dispatch(receiveObject(response.data))
      }).catch( error => handleErrors(error.message))
    )
;

export {
  searchObjects,
  loadNextObjects,
  loadObjectsPage,
  fetchObject
}
