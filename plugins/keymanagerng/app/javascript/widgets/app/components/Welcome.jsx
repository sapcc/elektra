import React from "react"

import { IntroBox } from "juno-ui-components"

const Welcome = () => (
  <>
    <IntroBox variant="hero" title="Welcome to keymanagerng">
      <p>
        This is an example for how to build a simple react app inside Elektra.
      </p>

      <h5>Folder structure:</h5>

      <ul>
        <li>
          <strong>components:</strong> contains jsx components which can be
          stateful or stateless.
        </li>
        <li>
          <strong>reducers:</strong> contains all the methods which are
          responsible for manipulating the state.
        </li>
      </ul>
    </IntroBox>
  </>
)

export default Welcome
