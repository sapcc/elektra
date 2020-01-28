import React from 'react'
import {useGlobalState} from './StateProvider'

const Miau = () => {
  const state = useGlobalState()
  console.log('render Miau')
  return (
    <h1>
      Miauu {state.count.count}
    </h1>
  )
}

export default Miau