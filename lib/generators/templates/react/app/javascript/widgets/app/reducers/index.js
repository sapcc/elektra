import entries from "./entries"

const combineReducers = (slices) => (state, action) =>
  Object.keys(slices).reduce(
    // use for..in loop, if you prefer it
    (acc, prop) => ({
      ...acc,
      [prop]: slices[prop](acc[prop], action),
    }),
    state
  )

const initialState = { entries: entries({}, {}) } // some state for props a, b
const rootReducer = combineReducers({ entries })

export default rootReducer
export { initialState }
