import * as constants from "../constants"

//  ########################### EVENTS ##############################
const initialEventState = {
  error: null,
  total: 0,
  offset: 0,
  currentPage: 1,
  limit: 30,
  items: [],
  isFetching: false,
  filterStartTime: "",
  filterEndTime: "",
  filterType: "",
  filterTerm: "",
  attributeValues: "",
  isFetchingAttributeValues: false,
  activeFilters: [],
}

const updateItemInList = (state, idKey, idValue, newValues) => {
  const index = state.items.findIndex((item) => item[idKey] === idValue)
  if (index < 0) return state

  // create a copy of state
  let newState = { ...state }
  // create a copy of items
  newState.items = state.items.slice()
  // update item's attributes
  Object.assign(newState.items[index], newValues)
  return newState
}

const updateFilterStartTime = (state, { filterStartTime }) =>
  Object.assign({}, state, { filterStartTime })

const updateFilterEndTime = (state, { filterEndTime }) =>
  Object.assign({}, state, { filterEndTime })

const updateFilterType = (state, { filterType }) =>
  Object.assign({}, state, { filterType })

const updateFilterTerm = (state, { filterTerm }) =>
  Object.assign({}, state, { filterTerm })

const addFilter = (state) => {
  let newState = { ...state }
  let foundFilter = newState.activeFilters.find(
    (filter) => filter[0] == newState.filterType
  )
  // only add if a filter for this type doesn't exist yet
  !foundFilter &&
    Object.assign(newState.activeFilters, [
      ...newState.activeFilters,
      [newState.filterType, newState.filterTerm],
    ])

  return newState
}

const deleteFilter = (state, { filterType }) =>
  Object.assign(state, {
    activeFilters: state.activeFilters.filter(
      (filter) => filter[0] != filterType
    ),
  })

const clearAllFilters = (state, {}) =>
  Object.assign(state, { activeFilters: [] })

const updateOffset = (state, { offset }) => Object.assign({}, state, { offset })

const updateCurrentPage = (state, { page }) =>
  Object.assign({}, state, { currentPage: page })

const requestEvents = (state, {}) =>
  Object.assign({}, state, { isFetching: true })

const requestEventsFailure = (state, { error }) =>
  Object.assign({}, state, { isFetching: false, error })

const receiveEvents = (state, { events, total }) =>
  Object.assign({}, state, {
    isFetching: false,
    items: events,
    total: total,
    error: null,
  })

const requestAttributeValues = (state, {}) =>
  Object.assign({}, state, {
    isFetchingAttributeValues: true,
  })

const requestAttributeValuesFailure = (state, { error }) =>
  Object.assign({}, state, {
    isFetchingAttributeValues: false,
    error,
  })

const requestAttributeValuesNotFound = (state, { attribute }) => {
  let attributeValues = {}
  attributeValues[attribute] = []

  return Object.assign({}, state, {
    isFetchingAttributeValues: false,
    attributeValues: Object.assign({}, state.attributeValues, attributeValues), // set attribute value to empty array in attributeValues hash
    error: null,
  })
}

const receiveAttributeValues = (state, { attribute, values }) => {
  let attributeValues = {}
  attributeValues[attribute] = values

  return Object.assign({}, state, {
    isFetchingAttributeValues: false,
    attributeValues: Object.assign({}, state.attributeValues, attributeValues), // merge attribute: values into attributeValues hash
    error: null,
  })
}

// Event Details
const toggleEventDetailsVisible = (state, { eventId, detailsVisible }) =>
  updateItemInList(state, "id", eventId, { detailsVisible })

const requestEventDetails = (state, { eventId }) =>
  updateItemInList(state, "id", eventId, { isFetchingDetails: true })

const requestEventDetailsFailure = (state, { eventId, error }) =>
  updateItemInList(state, "id", eventId, { isFetchingDetails: false, error })

const receiveEventDetails = (state, { eventId, eventDetails }) =>
  updateItemInList(state, "id", eventId, {
    details: eventDetails,
    isFetchingDetails: false,
    error: null,
  })

// events reducer
export const events = function (state, action) {
  if (state == null) {
    state = initialEventState
  }
  switch (action.type) {
    case constants.REQUEST_EVENTS:
      return requestEvents(state, action)
    case constants.RECEIVE_EVENTS:
      return receiveEvents(state, action)
    case constants.REQUEST_EVENTS_FAILURE:
      return requestEventsFailure(state, action)
    case constants.REQUEST_ATTRIBUTE_VALUES:
      return requestAttributeValues(state, action)
    case constants.RECEIVE_ATTRIBUTE_VALUES:
      return receiveAttributeValues(state, action)
    case constants.REQUEST_ATTRIBUTE_VALUES_FAILURE:
      return requestAttributeValuesFailure(state, action)
    case constants.REQUEST_ATTRIBUTE_VALUES_NOT_FOUND:
      return requestAttributeValuesNotFound(state, action)
    case constants.UPDATE_FILTER_START_TIME:
      return updateFilterStartTime(state, action)
    case constants.UPDATE_FILTER_END_TIME:
      return updateFilterEndTime(state, action)
    case constants.UPDATE_FILTER_TYPE:
      return updateFilterType(state, action)
    case constants.UPDATE_FILTER_TERM:
      return updateFilterTerm(state, action)
    case constants.ADD_FILTER:
      return addFilter(state, action)
    case constants.DELETE_FILTER:
      return deleteFilter(state, action)
    case constants.CLEAR_ALL_FILTERS:
      return clearAllFilters(state, action)
    case constants.UPDATE_OFFSET:
      return updateOffset(state, action)
    case constants.UPDATE_CURRENT_PAGE:
      return updateCurrentPage(state, action)
    case constants.TOGGLE_EVENT_DETAILS_VISIBLE:
      return toggleEventDetailsVisible(state, action)
    case constants.REQUEST_EVENT_DETAILS:
      return requestEventDetails(state, action)
    case constants.REQUEST_EVENT_DETAILS_FAILURE:
      return requestEventDetailsFailure(state, action)
    case constants.RECEIVE_EVENT_DETAILS:
      return receiveEventDetails(state, action)
    default:
      return state
  }
}
