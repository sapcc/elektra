/* eslint no-console:0 */
import { BrowserRouter, Route, Redirect, Switch } from "react-router-dom"
import Interconnections from "./components/interconnections/list"
import ShowInterconnection from "./components/interconnections/show"
import NewInterconnection from "./components/interconnections/new"
import StateProvider from "./stateProvider"

// render all components inside a hash router
const App = () => {
  return (
    <StateProvider
      stateKeys={[
        "interconnections",
        "cachedProjects",
        "cachedInterconnections",
        "cachedBgpVpns",
      ]}
    >
      <BrowserRouter basename={`${window.location.pathname}?r=`}>
        <Route path="/" component={Interconnections} />
        <Switch>
          <Route path="/new" component={NewInterconnection} />
          <Route path="/:id/:tab?" component={ShowInterconnection} />
        </Switch>
      </BrowserRouter>
    </StateProvider>
  )
}

export default App
