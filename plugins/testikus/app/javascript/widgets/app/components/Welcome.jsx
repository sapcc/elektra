import React from "react"

const Welcome = () => (
  <div className="p-4">
    <h4>Welcome to testikus</h4>
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
