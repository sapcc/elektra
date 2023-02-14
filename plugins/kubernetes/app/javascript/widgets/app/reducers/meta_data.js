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
const initialMetaDataState = {
  flavors: [
    {
      id: "m1.small",
      name: "m1.small",
    },
    {
      id: "m1.medium",
      name: "m1.medium",
    },
    {
      id: "m1.xmedium",
      name: "m1.xmedium",
    },
    {
      id: "m1.large",
      name: "m1.large",
    },
    {
      id: "m1.xlarge",
      name: "m1.xlarge",
    },
    {
      id: "m1.10xlarge",
      name: "m1.10xlarge",
    },
    {
      id: "x1.2xmemory",
      name: "x1.2xmemory",
    },
  ],
  availabilityZones: [],
  loaded: false,
  error: null,
  isFetching: false,
}

const requestMetaData = function (state, ...rest) {
  const obj = rest[0]
  return ReactHelpers.mergeObjects({}, state, {
    isFetching: true,
    error: null,
  })
}

const requestMetaDataFailure = function (state, { error }) {
  const oldErrorCount = state.errorCount || 0
  return ReactHelpers.mergeObjects({}, state, {
    isFetching: false,
    error,
    errorCount: oldErrorCount + 1,
  })
}

const receiveMetaData = function (state, { metaData }) {
  metaData.availabilityZones.sort((a, b) => b.name.localeCompare(a.name))
  return ReactHelpers.mergeObjects({}, metaData, {
    isFetching: false,
    error: null,
    loaded: true,
  })
}

const metaData = function (state, action) {
  if (state == null) {
    state = initialMetaDataState
  }
  switch (action.type) {
    case constants.REQUEST_META_DATA:
      return requestMetaData(state, action)
    case constants.REQUEST_META_DATA_FAILURE:
      return requestMetaDataFailure(state, action)
    case constants.RECEIVE_META_DATA:
      return receiveMetaData(state, action)
    default:
      return state
  }
}

export default metaData
