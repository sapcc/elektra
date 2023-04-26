import React from "react"
import { byteToHuman } from "lib/tools/size_formatter"
import { Tooltip } from "lib/components/Overlay"

export const PrettySize = ({ size }) => {
  return (
    <Tooltip content={size + " Bytes"} placement="top">
      <span>{byteToHuman(size)}</span>
    </Tooltip>
  )
}
