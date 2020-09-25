import * as constants from "../constants"

//########################## TYPES ##############################
const initialState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false,
}

const request = (state, { requestedAt }) => ({
  ...state,
  isFetching: true,
  requestedAt,
})

const requestFailure = (state) => ({ ...state, isFetching: false })

const receive = (state, { aggregates, receivedAt }) => ({
  ...state,
  isFetching: false,
  items: aggregates,
  receivedAt,
})

// entries reducer
export default (state, action) => {
  if (state == null) {
    state = initialState
  }
  switch (action.type) {
    case constants.RECEIVE_AGGREGATES:
      return receive(state, action)
    case constants.REQUEST_AGGREGATES:
      return request(state, action)
    case constants.REQUEST_AGGREGATES_FAILURE:
      return requestFailure(state, action)
    default:
      return state
  }
}
