import * as constants from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const ajaxHelper = pluginAjaxHelper('block-storage')
const errorMessage = (error) =>
  error.response && error.response.data && error.response.data.errors ||
  error.message

// #################### Availability Zones ################
const requestAvailabilityZones= () => (
  {
    type: constants.REQUEST_AVAILABILITY_ZONES,
    requestedAt: Date.now()
  }
)

const requestAvailabilityZonesFailure= (error) => (
  {
    type: constants.REQUEST_AVAILABILITY_ZONES_FAILURE,
    error
  }
);

const receiveAvailabilityZones= (items) =>
  ({
    type: constants.RECEIVE_AVAILABILITY_ZONES,
    items
  })
;

const fetchAvailabilityZones= () =>
  (dispatch) => {
    dispatch(requestAvailabilityZones());

    ajaxHelper.get(`/volumes/availability-zones`).then( (response) => {
      dispatch(receiveAvailabilityZones(response.data.availability_zones));
    })
    .catch( (error) => {
      dispatch(requestAvailabilityZonesFailure(errorMessage(error)));
    })
  }
;

const shouldFetchAvailabilityZones= (state) => {
  if (state.availabilityZones.isFetching || state.availabilityZones.requestedAt) {
    return false;
  } else {
    return true;
  }
};

const fetchAvailabilityZonesIfNeeded= () =>
  (dispatch, getState) => {
    if (shouldFetchAvailabilityZones(getState())) {
      return dispatch(fetchAvailabilityZones());
    }
  }
;

//################### VOLUMES #########################
const receiveVolume= (volume) =>
  ({
    type: constants.RECEIVE_VOLUME,
    volume
  })
;

const requestVolumeDelete= (id) => (
  {
    type: constants.REQUEST_VOLUME_DELETE,
    id
  }
)

const removeVolume= (id) => (
  {
    type: constants.REMOVE_VOLUME,
    id
  }
)

const fetchVolume= (id) =>
  (dispatch) => {
    return new Promise((handleSuccess,handleError) =>
      ajaxHelper.get(`/volumes/${id}`).then( (response) => {
        dispatch(receiveVolume(response.data.volume));
        handleSuccess(response.data.volume)
      })
      .catch( (error) => {
        if(error.response.status == 404) {
          dispatch(removeVolume(id))
        } else {
          handleError(errorMessage(error))
        }
      })
    )
  }
;

const deleteVolume=(id) =>
  (dispatch) =>
    confirm(`Do you really want to delete the volume ${id}?`).then(() => {
      return ajaxHelper.delete(`/volumes/${id}`)
      .then(response => dispatch(requestVolumeDelete(id)))
      .catch( (error) => {
        addError(React.createElement(ErrorsList, {
          errors: errorMessage(error)
        }))
      });
    }).catch(cancel => true)

const forceDeleteVolume=(id) =>
  (dispatch) =>
    confirm(`Do you really want to delete the volume ${id}?`).then(() => {
      return ajaxHelper.delete(`/volumes/${id}/force-delete`)
      .then(response => dispatch(requestVolumeDelete(id)))
      .catch( (error) => {
        addError(React.createElement(ErrorsList, {
          errors: errorMessage(error)
        }))
      });
    }).catch(cancel => true)

//################################

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

const fetchVolumes= () =>
  function(dispatch,getState) {
    dispatch(requestVolumes());

    const { marker } = getState().volumes
    const params = {}
    if(marker) params['marker'] = marker.id

    return ajaxHelper.get('/volumes', {params: params }).then( (response) => {
      dispatch(receiveVolumes(response.data.volumes, response.data.has_next));
    })
    .catch( (error) => {
      dispatch(requestVolumesFailure(errorMessage(error)));
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
    type: constants.SET_VOLUME_SEARCH_TERM,
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

//################ VOLUME FORM ###################
const submitNewVolumeForm= (values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.post('/volumes/', { volume: values }
      ).then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
        addNotice('Volume is being created.')
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

const submitEditVolumeForm= (id,values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.put(`/volumes/${id}`, { volume: values }
      ).then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

const submitResetVolumeStatusForm= (id,values) => (
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) =>
      ajaxHelper.put(`/volumes/${id}/reset-status`, { status: values }
      ).then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
      }).catch(error => handleErrors({errors: errorMessage(error)}))
    )
);

const requestVolumeAttach= (id) => (
  {
    type: constants.REQUEST_VOLUME_ATTACH,
    id
  }
)

const requestVolumeDetach= (id) => (
  {
    type: constants.REQUEST_VOLUME_DETACH,
    id
  }
)

const attachVolume=(id, serverId) =>
  (dispatch) =>
    new Promise((handleSuccess,handleErrors) => {
      ajaxHelper.put(`/volumes/${id}/attach`, {server_id: serverId})
        .then((response) => {
          dispatch(requestVolumeAttach(id))
          handleSuccess()
        })
        .catch(error => handleErrors({errors: errorMessage(error)}))
    })

const detachVolume=(id, attachmentId) =>
  (dispatch) =>
    confirm(`Do you really want to delete the volume ${id}?`).then(() => {
      return new Promise((handleSuccess,handleErrors) => {
        ajaxHelper.put(`/volumes/${id}/detach`, {attachment_id: attachmentId})
          .then((response) => {
            dispatch(requestVolumeDetach(id))
            handleSuccess()
          })
          .catch(error => handleErrors({errors: errorMessage(error)}))
      })
    }).catch(cancel => true)

export {
  fetchVolumesIfNeeded,
  fetchVolume,
  fetchAvailabilityZonesIfNeeded,
  searchVolumes,
  deleteVolume,
  forceDeleteVolume,
  attachVolume,
  detachVolume,
  submitNewVolumeForm,
  submitEditVolumeForm,
  submitResetVolumeStatusForm,
  loadNext
}
