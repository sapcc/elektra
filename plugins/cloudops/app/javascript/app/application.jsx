/* eslint no-console:0 */
import { HashRouter, Route, Switch } from 'react-router-dom'

import Menu from './menu';
import SearchRoutes from './search/components/routes'
import { withRouter } from 'react-router'


let Breadcrumb = (props) => {
  // crumbName = (string) => {
  //   if (string.startsWith('/')) {
  //     string = string.substring(1); // cut off leading slash
  //   }
  //
  //   // upcase first letter
  //   string = string.charAt(0).toUpperCase() + string.slice(1);
  //
  //
  //   return (
  //     string
  //   )
  // }

  return(
    <div className="main-toolbar">
      <div className="container">
        <h1>
          <div className="page-title">
            <i className="fa fa-angle-right"></i>
            &nbsp;
            { props.location && props.location.pathname}
          </div>
        </h1>
      </div>
    </div>
  )
}

Breadcrumb = withRouter(Breadcrumb)


// render all components inside a hash router
export default (props) =>
  <HashRouter /*hashType="noslash"*/ >
    <React.Fragment>
      <Menu/>
      <Breadcrumb/>

      <div className="container">
        <Switch>
            <SearchRoutes/>
        </Switch>
      </div>
    </React.Fragment>
  </HashRouter>
