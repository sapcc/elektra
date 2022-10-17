const initialState = {
  items: [],
  isFetching: false,
  error: null,
  loaded: false,
}

const sortByName = (a, b) => (a.name < b.name ? -1 : a.name > b.name ? 1 : 0)

const requestContainers = (containersState) => {
  return { ...containersState, isFetching: true, error: null }
}

const receiveContainers = (containersState, action) => {
  if (action.containers) {
    return {
      ...containersState,
      isFetching: false,
      error: null,
      items: action.containers.sort(sortByName),
      loaded: true,
    }
  } else if (action.item) {
    const containers = containersState.items.slice()
    const index = containers.findIndex(
      (i) => i.container_ref.indexOf(action.item.id) >= 0
    )
    if (index >= 0) {
      containers[index] = { ...containers[index], ...action.item }
    } else {
      containers.push(action.item)
    }
    return {
      ...containersState,
      isFetching: false,
      error: null,
      items: containers.sort(sortByName),
    }
  }
  return containersState
}

const requestContainersFailure = (containersState, action) => {
  return { ...containersState, isFetching: false, error: action.error }
}

const deleteContainers = (containersState, action) => {
  const index = containersState.items.findIndex(
    (i) => i.container_ref.indexOf(action.id) >= 0
  )
  if (index < 0) return containersState
  const containers = containersState.items.slice()
  containers.splice(index, 1)
  return { ...containersState, items: containers, error: null }
}

const requestDeleteContainers = (containersState, action) => {
  const index = containersState.items.findIndex(
    (i) => i.container_ref.indexOf(action.id) >= 0
  )
  if (index < 0) return containersState
  const containers = containersState.items.slice()
  containers[index] = { ...containers[index], isDeleting: true }
  return { ...containersState, items: containers }
}

const deleteContainersFailure = (containersState, action) => {
  const index = containersState.items.findIndex(
    (i) => i.container_ref.indexOf(action.id) >= 0
  )
  if (index < 0) return containersState
  const containers = containersState.items.slice()
  containers[index] = { ...containers[index], isDeleting: false }
  return { ...containersState, items: containers, error: action.error }
}

export default (containersState = initialState, action) => {
  switch (action.type) {
    case "REQUEST_CONTAINERS":
      return requestContainers(containersState)
    case "RECEIVE_CONTAINERS":
      return receiveContainers(containersState, action)
    case "REQUEST_CONTAINERS_FAILURE":
      return requestContainersFailure(containersState, action)
    case "DELETE_CONTAINERS":
      return deleteContainers(containersState, action)
    case "REQUEST_DELETE_CONTAINERS":
      return requestDeleteContainers(containersState, action)
    case "DELETE_CONTAINERS_FAILURE":
      return deleteContainersFailure(containersState, action)
    default:
      return containersState
  }
}
