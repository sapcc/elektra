/* eslint no-console:0 */
import { HashRouter, Route, Switch } from 'react-router-dom'

import Menu from './menu';
import SearchRoutes from './search/components/routes'

// render all components inside a hash router
export default (props) =>
  <HashRouter /*hashType="noslash"*/ >
    <Switch>
      <Route exact path="/" component={Menu}/>

      <SearchRoutes/>
    </Switch>
  </HashRouter>
