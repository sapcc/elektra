/* eslint no-console:0 */
import React from "react"
import { HashRouter, Route, Redirect } from "react-router-dom"

import Tabs from "./Tabs"
import Welcome from "./Welcome"

import Entries from "./entries/list"
import EditEntryModal from "./entries/edit"
import ShowEntryModal from "./entries/show"
import NewEntryModal from "./entries/new"
import StateProvider from "./StateProvider"

const tabsConfig = [
  { to: "/welcome", label: "Welcome", component: Welcome },
  { to: "/entries", label: "Entries", component: Entries },
]

// render all components inside a hash router
const Application = () => {
  return (
    <HashRouter /*hashType="noslash"*/>
      <StateProvider>
        {/* redirect root to shares tab */}
        <Route exact path="/" render={() => <Redirect to="/welcome" />} />
        <Route path="/:activeTab">
          <Tabs tabsConfig={tabsConfig} />
        </Route>

        <Route exact path="/entries/new" component={NewEntryModal} />
        <Route exact path="/entries/:id/show" component={ShowEntryModal} />
        <Route exact path="/entries/:id/edit" component={EditEntryModal} />
      </StateProvider>
    </HashRouter>
  )
}

export default Application
