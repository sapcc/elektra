import { Route } from 'react-router-dom'

import Home from '../containers/home';
import ShowItemModal from '../containers/show'

export default () =>
  <React.Fragment>
    <Route path="/search" component={Home}/>
    <Route exact path='/search/:id/show' component={ShowItemModal}/>
  </React.Fragment>
