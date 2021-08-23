/* eslint no-console:0 */
import { HashRouter, Route, Redirect } from "react-router-dom"

import Tabs from "./tabs"
import Welcome from "./welcome"

import Entries from "../containers/entries/list"
import EditEntryModal from "../containers/entries/edit"
import ShowEntryModal from "../containers/entries/show"
import NewEntryModal from "../containers/entries/new"

const tabsConfig = [
  { to: "/welcome", label: "Welcome", component: Welcome },
  { to: "/entries", label: "Entries", component: Entries },
]

// render all components inside a hash router
export default (props) => (
  <HashRouter /*hashType="noslash"*/>
    <div>
      {/* redirect root to shares tab */}
      <Route exact path="/" render={() => <Redirect to="/welcome" />} />
      <Route
        path="/:activeTab"
        children={({ match, location, history }) =>
          React.createElement(
            Tabs,
            Object.assign({}, { match, location, history, tabsConfig }, props)
          )
        }
      />

      <Route exact path="/entries/new" component={NewEntryModal} />
      <Route exact path="/entries/:id/show" component={ShowEntryModal} />
      <Route exact path="/entries/:id/edit" component={EditEntryModal} />
    </div>
  </HashRouter>
)
