
const initialState ={
  count: 0
}

export default (state = initialState, action) => {
  switch (action.type) {
    case 'increment2':
      return {count: state.count + 1}
    case 'decrement2':
      return {count: state.count - 1}
    default:
      return state
  }
}
