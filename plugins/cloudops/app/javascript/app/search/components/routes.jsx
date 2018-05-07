import { Route } from 'react-router-dom'

import Home from '../containers/home';
import ShowItemModal from '../containers/show'

export default () =>
  <React.Fragment>
    <Route path="/universal-search" component={Home}/>
    <Route exact path='/universal-search/:id/show' component={ShowItemModal}/>
  </React.Fragment>
