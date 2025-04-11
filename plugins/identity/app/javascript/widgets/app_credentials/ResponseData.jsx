import React from "react"
import { ButtonRow, Button, CodeBlock, Message } from "@cloudoperators/juno-ui-components"

export function ResponseData({ appCredential, onConfirm }) {
  return (
    <div>
      <Message variant="warning" text="Please copy the secret after close it will be gone" />
      <CodeBlock content={appCredential.secret} />
      <ButtonRow>
        <Button label="Confirm and Close" onClick={onConfirm} />
      </ButtonRow>
    </div>
  )
}
