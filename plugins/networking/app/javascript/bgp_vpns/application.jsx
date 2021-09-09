/* eslint no-console:0 */
import { BrowserRouter, Route, Redirect } from "react-router-dom"
import BgpVpns from "./components/bgp_vpns/list"
import ShowBgpVpn from "./components/bgp_vpns/show"
import StateProvider from "./stateProvider"

// render all components inside a hash router
const App = (props) => {
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
        <Route path="/:id" component={ShowBgpVpn} />
      </BrowserRouter>
    </StateProvider>
  )
}

export default App
