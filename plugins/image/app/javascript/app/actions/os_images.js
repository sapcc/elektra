import { imageConstants } from '../constants';
import { pluginAjaxHelper } from 'ajax_helper';
import { confirm } from 'lib/dialogs';
import { addNotice, addError } from 'lib/flashes';

import { ErrorsList } from 'lib/elektra-form/components/errors_list';

const ajaxHelper = pluginAjaxHelper('image')

export default (type) => {
  const constants = imageConstants(type)

  //################### IMAGES #########################
  const requestOsImages= () =>
    ({
      type: constants.REQUEST_IMAGES,
      requestedAt: Date.now()
    })
  ;

  const requestOsImagesFailure= () => ({type: constants.REQUEST_IMAGES_FAILURE});

  const receiveOsImages= (json, hasNext) =>
    ({
      type: constants.RECEIVE_IMAGES,
      osImages: json,
      hasNext,
      receivedAt: Date.now()
    })
  ;

  const requestOsImage= osImageId =>
    ({
      type: constants.REQUEST_IMAGE,
      osImageId,
      requestedAt: Date.now()
    })
  ;

  const requestOsImageFailure= osImageId =>
    ({
      type: constants.REQUEST_IMAGE_FAILURE,
      osImageId
    })
  ;

  const receiveOsImage= json =>
    ({
      type: constants.RECEIVE_IMAGE,
      osImage: json
    })
  ;

  const fetchOsImages= () =>
    function(dispatch,getState) {
      dispatch(requestOsImages());
      const { items } = getState()[type]
      const marker = items.length > 0 ? items[items.length-1] : null
      const params = {type}
      if(marker) params['marker'] = marker.id

      return ajaxHelper.get('/ng/images', {params: params }).then( (response) => {
        if (response.data.errors) {
          addError(React.createElement(ErrorsList, {errors: response.data.errors}))
        } else {
          dispatch(receiveOsImages(response.data.os_images, response.data.has_next));
        }
      })
      .catch( (error) => {
        dispatch(requestOsImagesFailure());
        addError(`Could not load images (${error.message})`)
      });
    }
  ;

  const loadNext= () =>
    function(dispatch, getState) {
      let state = getState()[type];

      if(!state.isFetching && state.hasNext) {
        dispatch(fetchOsImages(state.currentPage+1)).then(() => {
          // load next if search modus (searchTerm is presented)
          dispatch(loadNextOnSearch(state.searchTerm))
        })
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

  const searchOsImages= (searchTerm) =>
    function(dispatch) {
      dispatch(setSearchTerm(searchTerm))
      dispatch(loadNextOnSearch(searchTerm))
    }
  ;

  const shouldFetchOsImages= function(state) {
    const osImages = state[type];
    if (osImages.isFetching || osImages.requestedAt) {
      return false;
    } else {
      return true;
    }
  };

  const fetchOsImagesIfNeeded= () =>
    function(dispatch, getState) {
      if (shouldFetchOsImages(getState())) { return dispatch(fetchOsImages()); }
    }
  ;

  const canReloadOsImage= function(state,osImageId) {
    const { items } = state[type];
    let index = items.findIndex(i=>i.id==osImageId)
    if (index<0) { return true; }
    return !items[index].isFetching;
  };

  const reloadOsImage= osImageId =>
    function(dispatch,getState) {
      if (!canReloadOsImage(getState(),osImageId)) { return; }

      dispatch(requestOsImage(osImageId));
      ajaxHelper.get(`/osImages/${osImageId}`)
        .then((response) => dispatch(receiveOsImage(response.data)))
        .catch((error) => {
          dispatch(requestOsImageFailure());
        }
      )
    }
  ;

  const requestDelete=osImageId =>
    ({
      type: constants.REQUEST_DELETE_IMAGE,
      osImageId
    })
  ;

  const deleteOsImageFailure=osImageId =>
    ({
      type: constants.DELETE_IMAGE_FAILURE,
      osImageId
    })
  ;

  const removeOsImage=osImageId =>
    ({
      type: constants.DELETE_IMAGE_SUCCESS,
      osImageId
    })
  ;

  const deleteOsImage= osImageId =>
    function(dispatch, getState) {
      const osImageSnapshots = [];
      // check if there are dependent snapshots.
      // Problem: the snapshots may not be loaded yet
      const { snapshots } = getState();
      if (snapshots && snapshots.items) {
        for (let snapshot of snapshots.items) {
          if (snapshot.osImage_id===osImageId) { osImageSnapshots.push(snapshot); }
        }
      }

      if (osImageSnapshots.length > 0) {
        return addNotice(`OsImage still has ${osImageSnapshots.length} dependent snapshots. Please remove dependent snapshots first.`)
      }

      confirm(`Do you really want to delete the osImage ${osImageId}?`).then(() => {
        dispatch(requestDelete(osImageId));
        ajaxHelper.delete(`/ng/images/${osImageId}`).then((response) => {
          if (response.data && response.data.errors) {
            addError(React.createElement(ErrorsList, {errors: response.data.errors}));
            dispatch(deleteOsImageFailure(osImageId))
          } else {
            dispatch(removeOsImage(osImageId));
          }
        }).catch((error) => {
          dispatch(deleteOsImageFailure(osImageId))
          addError(React.createElement(ErrorsList, {errors: error.message}));
        })
      }).catch((aborted) => null)
    }
  ;


  //################ IMAGE FORM ###################
  const submitEditOsImageForm= (values) => (
    (dispatch) =>
      new Promise((handleSuccess,handleErrors) =>
        ajaxHelper.put(
          `/ng/images/${values.id}`,
          { osImage: values }
        ).then((response) => {
          if (response.data.errors) handleErrors({errors: response.data.errors});
          else {
            dispatch(receiveOsImage(response.data))
            handleSuccess()
          }
        }).catch(error => handleErrors({errors:error.message}))
      )
  );

  const submitNewOsImageForm= (values) => (
    (dispatch) =>
      new Promise((handleSuccess,handleErrors) =>
        ajaxHelper.post(
          `/ng/images`,
          { osImage: values }
        ).then((response) => {
          if (response.data.errors) handleErrors({errors: response.data.errors});
          else {
            dispatch(receiveOsImage(response.data))
            handleSuccess()
          }
        }).catch(error => handleErrors({errors: error.message}))
      )
  );

  const updateImageVisibility = (imageId, visibility) => (
    (dispatch) => {
      dispatch(requestOsImage(imageId))
      return ajaxHelper.put(
        `/ng/images/${imageId}/update_visibility`,
        { id: imageId, visibility }
      ).then((response) => {
        if (response.data.errors)
          addError(React.createElement(ErrorsList, {errors: response.data.errors}));
        else {
          dispatch(receiveOsImage(response.data))
        }
      })
    }
  )

  return {
    requestOsImage,
    receiveOsImage,
    removeOsImage,
    fetchOsImagesIfNeeded,
    reloadOsImage,
    deleteOsImage,
    searchOsImages,
    loadNext,
    updateImageVisibility
  }
}
