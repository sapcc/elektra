/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS201: Simplify complex destructure assignments
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import ReactHelpers from "../lib/helpers"
import * as constants from "../constants"
//######################### CLUSTER FORM ###########################
const initialInfoState = {
  availableClusterVersions: [],
  defaultClusterVersion: "",
  gitVersion: "",
  supportedClusterVersions: [],
  loaded: false,
  error: null,
  isFetching: false,
}

const requestInfo = function (state, ...rest) {
  const obj = rest[0]
  return ReactHelpers.mergeObjects({}, state, {
    isFetching: true,
    error: null,
  })
}

const requestInfoFailure = function (state, { error }) {
  const oldErrorCount = state.errorCount || 0
  return ReactHelpers.mergeObjects({}, state, {
    isFetching: false,
    error,
    errorCount: oldErrorCount + 1,
  })
}

const receiveInfo = (state, { info }) =>
  ReactHelpers.mergeObjects({}, info, {
    isFetching: false,
    error: null,
    loaded: true,
  })

const info = function (state, action) {
  if (state == null) {
    state = initialInfoState
  }
  switch (action.type) {
    case constants.REQUEST_INFO:
      return requestInfo(state, action)
    case constants.REQUEST_INFO_FAILURE:
      return requestInfoFailure(state, action)
    case constants.RECEIVE_INFO:
      return receiveInfo(state, action)
    default:
      return state
  }
}
export default info
