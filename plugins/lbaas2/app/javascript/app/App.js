import {StateProvider} from './components/StateProvider'
import reducers from './reducers'
import Router from './components/Router'
// import { FlashMessages } from 'lib/flashes';
import FloatingFlashMessages from  './components/shared/FloatingFlashMessages'

const App = () => {
  console.log("RENDER App")
  return (
    <React.Fragment>
      {/* <FlashMessages/>*/}
      <FloatingFlashMessages/>
      <Router/>
    </React.Fragment>
  )
}

export default () => <StateProvider reducers={reducers}><App/></StateProvider>
