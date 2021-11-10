/* eslint no-console:0 */
import { BrowserRouter, Route, Redirect, Switch } from "react-router-dom"
import BgpVpns from "./components/bgp_vpns/list"
import ShowBgpVpn from "./components/bgp_vpns/show"
import NewBgpVpn from "./components/bgp_vpns/new"
import StateProvider from "./stateProvider"

// render all components inside a hash router
const App = () => {
  return (
    <StateProvider
      stateKeys={[
        "bgpvpns",
        "cachedProjects",
        "cachedRouters",
        "availableRouters",
      ]}
    >
      <BrowserRouter basename={`${window.location.pathname}?r=`}>
        <Route path="/" component={BgpVpns} />
        <Switch>
          <Route path="/new" component={NewBgpVpn} />
          <Route path="/:id/:tab?" component={ShowBgpVpn} />
        </Switch>
      </BrowserRouter>
    </StateProvider>
  )
}

export default App
