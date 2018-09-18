import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';

const ajaxHelper = pluginAjaxHelper('block-storage')

//################### IMAGES #########################
const requestVolumes= () => (
  {
    type: constants.REQUEST_VOLUMES,
    requestedAt: Date.now()
  }
)

const requestVolumesFailure= (error) => (
  {
    type: constants.REQUEST_VOLUMES_FAILURE,
    error
  }
);

const receiveVolumes= (items,hasNext) =>
  ({
    type: constants.RECEIVE_VOLUMES,
    items,
    hasNext,
    receivedAt: Date.now()
  })
;

// const fetchVolumes= () =>
//   function(dispatch) {
//     dispatch(requestVolumes());
//
//     return ajaxHelper.get('volumes').then( (response) => {
//       if (response.data.errors) {
//         throws(response.data.errors)
//       } else {
//         dispatch(receiveVolumes(response.data.volumes));
//       }
//     })
//     .catch( (error) => {
//       dispatch(requestVolumesFailure(error.message));
//     });
//   }
// ;
//
// const shouldFetchVolumes= function(state) {
//   const { volumes } = state;
//   if (volumes.isFetching || volumes.requestedAt) {
//     return false;
//   } else {
//     return true;
//   }
// };
//
// const fetchVolumesIfNeeded= () =>
//   function(dispatch, getState) {
//     if (shouldFetchVolumes(getState())) { return dispatch(fetchVolumes()); }
//   }
// ;

const fetchVolumes= () =>
  function(dispatch,getState) {
    dispatch(requestVolumes());

    const { marker } = getState().volumes
    const params = {}
    if(marker) params['marker'] = marker.id

    return ajaxHelper.get('/volumes', {params: params }).then( (response) => {
      if (response.data.errors) {
        throws(response.data.errors)
      } else {
        dispatch(receiveVolumes(response.data.volumes, response.data.has_next));
      }
    })
    .catch( (error) => {
      dispatch(requestVolumesFailure(error.message));
    });
  }
;

const loadNext= () =>
  function(dispatch, getState) {
    const {hasNext,isFetching,searchTerm} = getState().volumes;

    if(!isFetching && hasNext) {
      dispatch(fetchVolumes()).then(() => 
        // load next if search modus (searchTerm is presented)
        dispatch(loadNextOnSearch(searchTerm))
      )
    }
  }
;

const loadNextOnSearch=(searchTerm) =>
  function(dispatch) {
    if(searchTerm && searchTerm.trim().length>0) {
      dispatch(loadNext());
    }
  }
;

const setSearchTerm= (searchTerm) =>
  ({
    type: constants.SET_SEARCH_TERM,
    searchTerm
  })

const searchVolumes= (searchTerm) =>
  function(dispatch) {
    dispatch(setSearchTerm(searchTerm))
    dispatch(loadNextOnSearch(searchTerm))
  }
;

const shouldFetchVolumes= function(state) {
  if (state.volumes.isFetching || state.volumes.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchVolumesIfNeeded= () =>
  function(dispatch, getState) {
    if (shouldFetchVolumes(getState())) { return dispatch(fetchVolumes()); }
  }
;

export {
  fetchVolumesIfNeeded,
  searchVolumes,
  loadNext
}
