import { HashRouter, Route, Redirect } from "react-router-dom"
import { CASTELLUM_ERROR_TYPES } from "../constants"
import ErrorList from "../containers/error_list"
import React from "react"

const CastellumApp = (props) => {
  return (
    <HashRouter>
      <>
        {/* entry point */}
        <Route
          exact
          path="/"
          render={() => <Redirect to={`/${CASTELLUM_ERROR_TYPES[0]}`} />}
        />

        {/* error list tabs */}
        <Route
          exact
          path="/:errorType"
          render={(props) => (
            <ErrorList errorType={props.match.params.errorType} />
          )}
        />
      </>
    </HashRouter>
  )
}

export default CastellumApp
