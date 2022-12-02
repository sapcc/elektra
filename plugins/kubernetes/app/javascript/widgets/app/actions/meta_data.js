/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import * as constants from "../constants"
import { ajaxHelper } from "./ajax_helper"
// -------------- METADATA ---------------

const requestMetaData = () => ({ type: constants.REQUEST_META_DATA })

const requestMetaDataFailure = (error) => ({
  type: constants.REQUEST_META_DATA_FAILURE,
  error,
})

const receiveMetaData = (data) => ({
  type: constants.RECEIVE_META_DATA,
  metaData: data,
})

const setClusterFormDefaults = (data) => ({
  type: constants.SET_CLUSTER_FORM_DEFAULTS,
  metaData: data,
})

var loadMetaData = () =>
  function (dispatch, getState) {
    const { metaData } = getState()
    if (metaData != null && metaData.error === "") {
      return
    } // don't fetch if we already have the metadata

    dispatch(requestMetaData())

    return ajaxHelper.get("/api/v1/openstack/metadata", {
      contentType: "application/json",
      success(data) {
        dispatch(receiveMetaData(data))
        return dispatch(setClusterFormDefaults(data))
      },
      error(jqXHR) {
        const errorMessage =
          typeof jqXHR.responseJSON === "object"
            ? jqXHR.responseJSON.message
            : jqXHR.responseText
        dispatch(requestMetaDataFailure(errorMessage))
        // retry up to 20 times
        if (getState().metaData.errorCount <= 20) {
          return dispatch(loadMetaData())
        }
      },
    })
  }

// export
export { loadMetaData }
