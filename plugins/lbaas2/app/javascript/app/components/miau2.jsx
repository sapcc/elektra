import React from 'react'
import {useGlobalState} from './StateProvider'
import {useMemo} from 'react'

const Miau2 = () => {
  const state = useGlobalState()
  return useMemo(() => {
    console.log('render Miau2')
    return <h1>
      Miauu2 {state.count2.count}
    </h1>
  }, [state.count2])
}

export default Miau2