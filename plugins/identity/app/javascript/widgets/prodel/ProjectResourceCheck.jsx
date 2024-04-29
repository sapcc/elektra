import React from "react"
import { ContentAreaWrapper } from "juno-ui-components/build/ContentAreaWrapper"
import { Panel } from "juno-ui-components/build/Panel"
import { PanelBody } from "juno-ui-components/build/PanelBody"
import { apiClient } from "./lib/apiClient"
import { JsonViewer } from "juno-ui-components/build/JsonViewer"

export default function ProjectResourceCheck({ opened, onClose }) {
  React.useEffect(() => {
    apiClient
      .osApi("prodel")
      .get(`projects/${window.scopedProjectId}/resources/`)
      .then((response) => {
        console.log(response)
      })
  }, [])
  return (
    <ContentAreaWrapper>
      <Panel
        className="tw-z-[1050]"
        heading="Delete Project Resources Check"
        onClose={onClose}
        opened={opened}
      >
        <PanelBody>
          <h2>The following Resources are found:</h2>
          <JsonViewer
            toolbar
            theme="light"
            data={JSON.parse("{}")}
            expanded={1}
          />
        </PanelBody>
      </Panel>
    </ContentAreaWrapper>
  )
}
