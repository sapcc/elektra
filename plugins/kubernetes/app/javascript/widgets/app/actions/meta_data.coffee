import * as constants from "../constants"
import { ajaxHelper } from "./ajax_helper"
# -------------- METADATA ---------------

requestMetaData = () ->
  type: constants.REQUEST_META_DATA

requestMetaDataFailure = (error) ->
  type: constants.REQUEST_META_DATA_FAILURE
  error: error

receiveMetaData = (data) ->
  type: constants.RECEIVE_META_DATA
  metaData: data

setClusterFormDefaults = (data) ->
  type: constants.SET_CLUSTER_FORM_DEFAULTS
  metaData: data

loadMetaData = () ->
  (dispatch, getState) ->

    metaData = getState().metaData
    return if metaData? && metaData.error == ""  # don't fetch if we already have the metadata

    dispatch(requestMetaData())

    ajaxHelper.get "/api/v1/openstack/metadata",
      contentType: 'application/json'
      success: (data, textStatus, jqXHR) ->
        dispatch(receiveMetaData(data))
        dispatch(setClusterFormDefaults(data))
      error: ( jqXHR, textStatus, errorThrown) ->
        errorMessage =  if typeof jqXHR.responseJSON == 'object'
                          jqXHR.responseJSON.message
                        else jqXHR.responseText
        dispatch(requestMetaDataFailure(errorMessage))
        # retry up to 20 times
        if getState().metaData.errorCount <= 20
          dispatch(loadMetaData())

# export
export {
  loadMetaData
}
