import React from "react"
import { Stack } from "@cloudoperators/juno-ui-components"

const HintNotFound = ({ text }) => {
  return (
    <Stack
      alignment="center"
      distribution="center"
      direction="vertical"
      className="h-full"
    >
      <span>{text}</span>
    </Stack>
  )
}

export default HintNotFound
