import * as constants from "../constants"

const infoState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null,
  searchedValue: "",
}

const initialState = {
  data: null,
  requestedAt: null,
  receivedAt: null,
  isFetching: false,
  error: null,
  searchedValue: "",
  info: { ...infoState },
}

// ################## OBJECT ################

const setSearchedValue = function (state, { searchedValue }) {
  return { ...state, searchedValue }
}

const requestObject = function (state, { requestedAt }) {
  return { ...state, requestedAt, isFetching: true, data: null, error: null }
}

const receiveObject = function (state, { data, receivedAt }) {
  return { ...state, data, receivedAt, isFetching: false, error: null }
}

const requestObjectFailure = function (state, { error }) {
  return { ...state, error, isFetching: false, data: null }
}

// ################## OBJECT INFO ################

const requestObjectInfo = function (state, { requestedAt }) {
  state["info"] = Object.assign({}, infoState, state["info"], {
    isFetching: true,
    requestedAt,
    data: null,
    error: null,
  })
  return { ...state }
}

const receiveObjectInfo = function (state, { data, receivedAt }) {
  state["info"] = Object.assign({}, infoState, state["info"], {
    isFetching: false,
    receivedAt,
    data,
    error: null,
  })
  return { ...state }
}

const requestObjectInfoFailure = function (state, error) {
  state["info"] = Object.assign({}, infoState, state["info"], {
    isFetching: false,
    data: null,
    error,
  })
  return { ...state }
}

// ################## COMMON ################

const resetObject = (state) => ({ ...initialState })

export const object = function (state, action) {
  if (state == null) {
    state = initialState
  }
  switch (action.type) {
    case constants.SET_SEARCHED_VALUE:
      return setSearchedValue(state, action)
    case constants.REQUEST_OBJECT:
      return requestObject(state, action)
    case constants.REQUEST_OBJECT_FAILURE:
      return requestObjectFailure(state, action)
    case constants.RECEIVE_OBJECT:
      return receiveObject(state, action)

    case constants.REQUEST_OBJECTINFO:
      return requestObjectInfo(state, action)
    case constants.REQUEST_OBJECTINFO_FAILURE:
      return requestObjectInfoFailure(state, action)
    case constants.RECEIVE_OBJECTINFO:
      return receiveObjectInfo(state, action)

    case constants.RESET_STORE:
      return resetObject(state, action)

    default:
      return state
  }
}
