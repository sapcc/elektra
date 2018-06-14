import { Route } from 'react-router-dom'

import Home from '../containers/home';
import ShowItemModal from '../../search/containers/show'

export default () =>
  <React.Fragment>
    <Route path="/project-role-assignments" component={Home}/>
    <Route path='/project-role-assignments/:id/show' component={ShowItemModal}/>
  </React.Fragment>
