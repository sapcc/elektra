import React, {useMemo,useCallback} from 'react'
import ReactDOM from 'react-dom'
import {StateProvider, useGlobalState, useDispatch} from './components/StateProvider'
import reducers from './reducers'

// const initialState ={
//   count: 0
// }
//
// const reducer = (state = initialState, action) => {
//   switch (action.type) {
//     case 'increment':
//       return {count: state.count + 1}
//     case 'decrement':
//       return {count: state.count - 1}
//     default:
//       return state
//   }
// }
//
// const reducer2 = (state = initialState, action) => {
//   switch (action.type) {
//     case 'increment2':
//       return {count: state.count + 1}
//     case 'decrement2':
//       return {count: state.count - 1}
//     default:
//       return state
//   }
// }
//
// const reducers = {
//   test1: reducer,
//   test2: reducer2
// }


const PlusButton = () => {
  const dispatch = useDispatch()
  const increment = useCallback(() => dispatch({type:"increment"}),[])

  console.log('render PlusButton')

  return <button onClick={increment}>+</button>
}


const Miau = () => {
  const state = useGlobalState()

  console.log('render Miau')
  return <h1>
    Miauu {state.count.count}
  </h1>
}

const Miau2 = () => {
  const state = useGlobalState()

  return useMemo(() => {
    console.log('render Miau2')
    return <h1>
      Miauu2 {state.count2.count}
    </h1>
  }, [state.count2])
}

const App = () => {

  console.log("render App")
  return (
  <React.Fragment>
    <Miau/>
    <Miau2/>
    <PlusButton/>
  </React.Fragment>
  )
}

export default () => <StateProvider reducers={reducers}><App/></StateProvider>
