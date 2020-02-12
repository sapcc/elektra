import React, {useMemo,useCallback} from 'react'
import ReactDOM from 'react-dom'
import {StateProvider, useDispatch} from './components/StateProvider'
import reducers from './reducers'
import Router from './components/Router'


const PlusButton = () => {
  const dispatch = useDispatch()
  const increment = useCallback(() => dispatch({type:"increment"}),[])
  console.log('render PlusButton')
  return <button onClick={increment}>+</button>
}

const App = () => {
  console.log("render App")
  return (
    <Router/>
  )
}

export default () => <StateProvider reducers={reducers}><App/></StateProvider>
