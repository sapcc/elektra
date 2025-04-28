import React from "react"
import { ButtonRow, Button, CodeBlock, Message, Stack } from "@cloudoperators/juno-ui-components"

export function ResponseData({ appCredential, onConfirm }) {
  return (
    <div>
      <Stack direction="vertical" gap="3">
        <Message variant="info" text="Application Credential Created Successfully" />
        <Message
          variant="warning"
          text="Copy this secret and save it on a secure place. It will only be visible once and cannot be retrieved after closing this window. Store it securely"
        />
        <CodeBlock heading="Secret Key" content={appCredential.secret} />
        <ButtonRow>
          <Button label="Confirm and Close" onClick={onConfirm} />
        </ButtonRow>
      </Stack>
    </div>
  )
}
