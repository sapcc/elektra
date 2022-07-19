import React from "react"
import TagsList from "./List"

// this is the entrypoint for the react app
// instanceId comes from the tags.html.haml and was injected with the data tag
// you can also access instanceId via props.instanceId
const TagsApp = ({ instanceId }) => {
  return <TagsList instanceId={instanceId} />
}

export default TagsApp
