import React from "react"
import * as constants from "../constants"
import { pluginAjaxHelper } from "lib/ajax_helper"
import { confirm } from "lib/dialogs"
import { addNotice, addError } from "lib/flashes"

import { ErrorsList } from "lib/elektra-form/components/errors_list"

const ajaxHelper = pluginAjaxHelper("block-storage")
const errorMessage = (error) => error.data?.errors || error.message

// #################### Availability Zones ################
const requestAvailabilityZones = () => ({
  type: constants.REQUEST_AVAILABILITY_ZONES,
  requestedAt: Date.now(),
})

const requestAvailabilityZonesFailure = (error) => ({
  type: constants.REQUEST_AVAILABILITY_ZONES_FAILURE,
  error,
})

const receiveAvailabilityZones = (items) => ({
  type: constants.RECEIVE_AVAILABILITY_ZONES,
  items,
})
const fetchAvailabilityZones = () => (dispatch) => {
  dispatch(requestAvailabilityZones())

  ajaxHelper
    .get(`/volumes/availability-zones`)
    .then((response) => {
      dispatch(receiveAvailabilityZones(response.data.availability_zones))
    })
    .catch((error) => {
      dispatch(requestAvailabilityZonesFailure(errorMessage(error)))
    })
}
const shouldFetchAvailabilityZones = (state) => {
  if (
    state.availabilityZones.isFetching ||
    state.availabilityZones.requestedAt
  ) {
    return false
  } else {
    return true
  }
}

const fetchAvailabilityZonesIfNeeded = () => (dispatch, getState) => {
  if (shouldFetchAvailabilityZones(getState())) {
    return dispatch(fetchAvailabilityZones())
  }
}
// #################### Images ################
const requestImages = () => ({
  type: constants.REQUEST_IMAGES,
  requestedAt: Date.now(),
})

const requestImagesFailure = (error) => ({
  type: constants.REQUEST_IMAGES_FAILURE,
  error,
})

const receiveImages = (items) => ({
  type: constants.RECEIVE_IMAGES,
  items,
})
const fetchImages = () => (dispatch) => {
  dispatch(requestImages())

  ajaxHelper
    .get(`/volumes/images`)
    .then((response) => {
      dispatch(receiveImages(response.data.images))
    })
    .catch((error) => {
      dispatch(requestImagesFailure(errorMessage(error)))
    })
}
const shouldFetchImages = (state) => {
  if (state.images.isFetching || state.images.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchImagesIfNeeded = () => (dispatch, getState) => {
  if (shouldFetchImages(getState())) {
    return dispatch(fetchImages())
  }
}
//################### VOLUMES TYPES #########################

const requestVolumeTypes = () => ({
  type: constants.REQUEST_VOLUME_TYPES,
  requestedAt: Date.now(),
})

const receiveVolumeTypes = (types) => ({
  type: constants.RECEIVE_VOLUME_TYPES,
  types,
})
const requestVolumeTypesFailure = (error) => ({
  type: constants.REQUEST_VOLUME_TYPES_FAILURE,
  error,
})

const fetchVolumeTypes = () => (dispatch) => {
  dispatch(requestVolumeTypes())

  ajaxHelper
    .get(`/volumes/types`)
    .then((response) => {
      dispatch(receiveVolumeTypes(response.data.images))
    })
    .catch((error) => {
      dispatch(requestVolumeTypesFailure(errorMessage(error)))
    })
}

const shouldFetchVolumeTypes = (state) => {
  if (state.volumes.typesIsFetching || state.volumes.typesRequestedAt) {
    return false
  } else {
    return true
  }
}

const fetchVolumeTypesIfNeeded = () => (dispatch, getState) => {
  if (shouldFetchVolumeTypes(getState())) {
    return dispatch(fetchVolumeTypes())
  }
}

//################### VOLUMES #########################
const receiveVolume = (volume) => ({
  type: constants.RECEIVE_VOLUME,
  volume,
})
const requestVolumeDelete = (id) => ({
  type: constants.REQUEST_VOLUME_DELETE,
  id,
})

const removeVolume = (id) => ({
  type: constants.REMOVE_VOLUME,
  id,
})

const listenToVolumes = () => (dispatch) => {
  if (App && App.cable) {
    App.cable.subscriptions.create(
      { channel: "VolumesChannel", project_id: window.scopedProjectId },
      {
        received: (data) => {
          data.created && dispatch(receiveVolume(JSON.parse(data.created)))
          data.updated && dispatch(receiveVolume(JSON.parse(data.updated)))
          data.deleted && dispatch(removeVolume(data.deleted))
          data.detached && dispatch(requestVolumeDetach(data.detached))
          data.attached && dispatch(requestVolumeAttach(data.attached))
        },
      }
    )
  }
}

const fetchVolume = (id) => (dispatch) => {
  return new Promise((handleSuccess, handleError) =>
    ajaxHelper
      .get(`/volumes/${id}`)
      .then((response) => {
        dispatch(receiveVolume(response.data.volume))
        handleSuccess(response.data.volume)
      })
      .catch((error) => {
        if (error.status == 404) {
          dispatch(removeVolume(id))
        } else {
          handleError(errorMessage(error))
        }
      })
  )
}
const deleteVolume = (id) => (dispatch) =>
  confirm(`Do you really want to delete the volume ${id}?`)
    .then(() => {
      return ajaxHelper
        .delete(`/volumes/${id}`)
        .then((response) => dispatch(requestVolumeDelete(id)))
        .catch((error) => {
          addError(
            React.createElement(ErrorsList, {
              errors: errorMessage(error),
            })
          )
        })
    })
    .catch((cancel) => true)

const forceDeleteVolume = (id) => (dispatch) =>
  confirm(`Do you really want to delete the volume ${id}?`)
    .then(() => {
      return ajaxHelper
        .delete(`/volumes/${id}/force-delete`)
        .then((response) => dispatch(requestVolumeDelete(id)))
        .catch((error) => {
          addError(
            React.createElement(ErrorsList, {
              errors: errorMessage(error),
            })
          )
        })
    })
    .catch((cancel) => true)

//################################

const requestVolumes = () => ({
  type: constants.REQUEST_VOLUMES,
  requestedAt: Date.now(),
})

const requestVolumesFailure = (error) => ({
  type: constants.REQUEST_VOLUMES_FAILURE,
  error,
})

const receiveVolumes = ({
  items,
  has_next,
  page,
  limit,
  sort_key,
  sort_dir,
}) => ({
  type: constants.RECEIVE_VOLUMES,
  items,
  hasNext: has_next,
  page,
  limit,
  sortKey: sort_key,
  sortDir: sort_dir,
  receivedAt: Date.now(),
})
const fetchVolumes =
  ({ searchType, searchTerm, limit, page } = {}) =>
  (dispatch, getState) => {
    dispatch(requestVolumes({ searchType, searchTerm }))
    const params = { page: page || 1 }
    if (searchType && searchTerm) {
      params.search_type = searchType
      params.search_term = searchTerm
    }
    if (limit) params.limit = limit
    if (page > 1) {
      const volumes = getState().volumes
      if (volumes.items.length > 0) {
        params.marker = volumes.items[volumes.items.length - 1].id
      }
    }

    ajaxHelper
      .get("/volumes", { params })
      .then((response) => {
        dispatch(receiveVolumes(response.data))
      })
      .catch((error) => dispatch(requestVolumesFailure(errorMessage(error))))
  }

const shouldFetchVolumes = function (state) {
  if (state.volumes.isFetching || state.volumes.requestedAt) {
    return false
  } else {
    return true
  }
}

const fetchVolumesIfNeeded = () =>
  function (dispatch, getState) {
    if (shouldFetchVolumes(getState())) {
      return dispatch(fetchVolumes())
    }
  }
//################ VOLUME FORM ###################
const requestVolumeExtend = (id) => ({
  type: constants.REQUEST_VOLUME_EXTEND,
  id,
})

const submitNewVolumeForm = (values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .post("/volumes/", { volume: values })
      .then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
        addNotice("Volume is being created.")
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )

const submitEditVolumeForm = (id, values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .put(`/volumes/${id}`, { volume: values })
      .then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )

const submitResetVolumeStatusForm = (id, values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .put(`/volumes/${id}/reset-status`, { status: values })
      .then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )

const submitExtendVolumeSizeForm = (id, values) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .put(`/volumes/${id}/extend-size`, values)
      .then((response) => {
        dispatch(requestVolumeExtend(id))
        handleSuccess()
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )

const submitCloneVolumeForm = (values) => (dispatch) => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .post("/volumes/", { volume: values })
      .then((response) => {
        dispatch(receiveVolume(response.data))
        handleSuccess()
        addNotice("Volume is being created.")
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )
}

const submitVolumeToImageForm = (id, values) => (dispatch) => {
  return new Promise((handleSuccess, handleErrors) =>
    ajaxHelper
      .post(`/volumes/${id}/to-image`, { image: values })
      .then((response) => {
        handleSuccess()
        addNotice("Image is being uploaded.")
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  )
}
const requestVolumeAttach = (id) => ({
  type: constants.REQUEST_VOLUME_ATTACH,
  id,
})

const requestVolumeDetach = (id) => ({
  type: constants.REQUEST_VOLUME_DETACH,
  id,
})

const attachVolume = (id, serverId) => (dispatch) =>
  new Promise((handleSuccess, handleErrors) => {
    ajaxHelper
      .put(`/volumes/${id}/attach`, { server_id: serverId })
      .then((response) => {
        dispatch(requestVolumeAttach(id))
        handleSuccess()
      })
      .catch((error) => handleErrors({ errors: errorMessage(error) }))
  })

const detachVolume = (id, attachmentId) => (dispatch) =>
  confirm(`Do you really want to detach the volume ${id}?`)
    .then(() => {
      return new Promise((handleSuccess, handleErrors) => {
        ajaxHelper
          .put(`/volumes/${id}/detach`, { attachment_id: attachmentId })
          .then((response) => {
            dispatch(requestVolumeDetach(id))
            handleSuccess()
          })
          .catch((error) => handleErrors({ errors: errorMessage(error) }))
      })
    })
    .catch((cancel) => true)

export {
  fetchVolumes,
  fetchVolumesIfNeeded,
  fetchVolume,
  fetchAvailabilityZonesIfNeeded,
  fetchImagesIfNeeded,
  fetchVolumeTypesIfNeeded,
  deleteVolume,
  forceDeleteVolume,
  attachVolume,
  detachVolume,
  submitNewVolumeForm,
  submitEditVolumeForm,
  submitResetVolumeStatusForm,
  submitExtendVolumeSizeForm,
  submitCloneVolumeForm,
  submitVolumeToImageForm,
  listenToVolumes,
}
