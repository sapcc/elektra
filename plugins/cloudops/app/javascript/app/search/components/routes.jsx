import { Route } from 'react-router-dom'

import Home from '../containers/home';
import LiveSearchModal from '../containers/live_search';
import ShowItemModal from '../containers/show'

export default () =>
  <React.Fragment>
    <Route path="/universal-search" component={Home}/>
    <Route exact path='/universal-search/:id/show' component={ShowItemModal}/>
    <Route path="/universal-search/live" component={LiveSearchModal}/>
  </React.Fragment>
