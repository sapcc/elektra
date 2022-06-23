import React from "react"

const Welcome = () => (
  <div>
    <h4>Welcome to %{PLUGIN_NAME}</h4>
    <p>This is an example how to build simple react app inside elektra.</p>

    <h5>Folder structure</h5>

    <ul>
      <li>
        components: contains jsx components which can be state-full or
        state-less.
      </li>
      <li>
        reducers: contains all the methods which are responsible for
        manipulationg the state.
      </li>
    </ul>
  </div>
)

export default Welcome
