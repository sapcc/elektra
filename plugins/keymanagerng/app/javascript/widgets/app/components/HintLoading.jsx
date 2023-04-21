import React from "react"
import { Stack, Spinner } from "juno-ui-components"

const HintLoading = ({ text, className }) => {
  return (
    <Stack alignment="center" className={className}>
      <Spinner variant="primary" />
      {text ? <span>{text}</span> : <span>Loading...</span>}
    </Stack>
  )
}

export default HintLoading
