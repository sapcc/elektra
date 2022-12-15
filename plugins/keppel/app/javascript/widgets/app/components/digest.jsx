import HoverCopier from "./hovercopier"
import React from "react"
const Digest = ({ digest, wideDisplay, repositoryURL }) => {
  const [algo, hash] = digest.split(":")
  const shortDigest = wideDisplay ? digest : `${algo}:${hash.slice(0, 12)}… `

  const copyActions = [{ label: "Copy", value: digest }]
  if (repositoryURL) {
    copyActions.push({
      label: "Copy full URL",
      value: `${repositoryURL}@${digest}`,
    })
  }

  return (
    <HoverCopier
      shortText={shortDigest}
      longText={digest}
      actions={copyActions}
    />
  )
}

export default Digest
