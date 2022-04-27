import ReduxThunk from 'redux-thunk'
import configureStore from 'redux-mock-store'

export function setupStore(initialState) {
  const mockStore = configureStore([ReduxThunk])
  return mockStore(initialState)
}
