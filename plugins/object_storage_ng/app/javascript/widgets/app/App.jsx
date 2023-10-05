/* eslint no-console:0 */
import React from "react"
import PropTypes from "prop-types"
import StateProvider from "./StateProvider"
import Router from "./Router"
import StoreProvider from "./data/StoreProvider"

const App = (props) => (
  <StateProvider>
    <StoreProvider>
      <Router
        baseName={props.baseName}
        objectStoreEndpoint={props.objectStoreEndpoint}
      />
    </StoreProvider>
  </StateProvider>
)

App.propTypes = {
  baseName: PropTypes.string,
  objectStoreEndpoint: PropTypes.string,
}

export default App
