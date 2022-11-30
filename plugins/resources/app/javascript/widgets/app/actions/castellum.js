import React from "react"
import * as constants from "../constants"
import { createAjaxHelper } from "lib/ajax_helper"
import { addError } from "lib/flashes"
import { ErrorsList } from "lib/elektra-form/components/errors_list"

let ajaxHelper = null

export const configureCastellumAjaxHelper = (opts) => {
  ajaxHelper = createAjaxHelper(opts)
}

const castellumErrorMessage = (error) => {
  let msg = error.message
  if (error.data) {
    return `${msg}: ${error.data}`
  }
  return msg
}

const showCastellumError = (error) =>
  addError(
    React.createElement(ErrorsList, {
      errors: castellumErrorMessage(error),
    })
  )

export const fetchCastellumProjectConfig =
  (projectID) => (dispatch, getState) => {
    dispatch({
      type: constants.REQUEST_CASTELLUM_CONFIG,
      projectID,
      requestedAt: Date.now(),
    })

    return ajaxHelper
      .get(`/v1/projects/${projectID}`)
      .then((response) => {
        dispatch({
          type: constants.RECEIVE_CASTELLUM_CONFIG,
          projectID,
          data: response.data.resources,
          receivedAt: Date.now(),
        })
      })
      .catch((error) => {
        dispatch({
          type: constants.REQUEST_CASTELLUM_CONFIG_FAILURE,
          projectID,
          message: castellumErrorMessage(error),
        })
      })
  }

export const deleteCastellumProjectResource =
  (projectID, assetType) => (dispatch) =>
    new Promise((resolve) => {
      ajaxHelper
        .delete(`/v1/projects/${projectID}/resources/${assetType}`)
        .then((response) => {
          dispatch({
            type: constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG,
            projectID,
            assetType,
            data: null,
            receivedAt: Date.now(),
          })
          resolve()
        })
        .catch((error) => {
          //404 is not a problem
          const isNotFound = error.status == 404
          if (!isNotFound) {
            showCastellumError(error)
          }
          resolve()
        })
    })

export const updateCastellumProjectResource =
  (projectID, assetType, config) => (dispatch) =>
    new Promise((resolve) => {
      ajaxHelper
        .put(`/v1/projects/${projectID}/resources/${assetType}`, config)
        .then((response) => {
          dispatch({
            type: constants.RECEIVE_CASTELLUM_RESOURCE_CONFIG,
            projectID,
            assetType,
            data: config,
            receivedAt: Date.now(),
          })
          resolve()
        })
        .catch((error) => {
          showCastellumError(error)
          resolve()
        })
    })

const operationsReportKeys = {
  pending: "pending_operations",
  "recently-failed": "recently_failed_operations",
  "recently-succeeded": "recently_succeeded_operations",
}

const fetchOperationsReport = (domainID, reportType) => (dispatch) => {
  dispatch({
    type: constants.REQUEST_CASTELLUM_OPERATIONS_REPORT,
    reportType,
    requestedAt: Date.now(),
  })

  return ajaxHelper
    .get(`/v1/operations/${reportType}`, { domain: domainID })
    .then((response) => {
      const data = response.data[operationsReportKeys[reportType]] || []
      dispatch({
        type: constants.RECEIVE_CASTELLUM_OPERATIONS_REPORT,
        reportType,
        data,
        receivedAt: Date.now(),
      })
    })
    .catch((error) => {
      dispatch({
        type: constants.REQUEST_CASTELLUM_OPERATIONS_REPORT_FAILURE,
        reportType,
        message: castellumErrorMessage(error),
        receivedAt: Date.now(),
      })
    })
}

export const fetchOperationsReportIfNeeded =
  (domainID, reportType) => (dispatch, getState) => {
    const state = getState().castellum.operationsReports[reportType] || {}
    if (!state.isFetching && !state.requestedAt) {
      return dispatch(fetchOperationsReport(domainID, reportType))
    }
  }
