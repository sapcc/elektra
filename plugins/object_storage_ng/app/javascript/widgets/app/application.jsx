/* eslint no-console:0 */
import React from "react"
import PropTypes from "prop-types"
import StateProvider from "./stateProvider"
import Router from "./router"

const App = (props) => (
  <StateProvider>
    <Router
      baseName={props.baseName}
      objectStoreEndpoint={props.objectStoreEndpoint}
    />
  </StateProvider>
)

App.propTypes = {
  baseName: PropTypes.string,
  objectStoreEndpoint: PropTypes.string,
}

export default App
