import {StateProvider} from './components/StateProvider'
import reducers from './reducers'
import Router from './components/Router'

const App = () => {
  console.log("RENDER App")
  return (
    <Router/>
  )
}

export default () => <StateProvider reducers={reducers}><App/></StateProvider>
