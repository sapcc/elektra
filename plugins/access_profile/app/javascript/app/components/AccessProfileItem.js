import React, { useMemo, useState } from "react"
import ServiceAction from "./ServiceAction"
import { policy } from "lib/policy"
import SmartLink from "./shared/SmartLink"
import NewTag from "./NewTag"
import { Collapse } from "react-bootstrap"
import { FormStateProvider } from "./FormState"
import { scope } from "lib/ajax_helper"

const AccessProfileItem = ({ profileKey, items, reloadTags }) => {
  const [showNewForm, setShowNewForm] = useState(false)
  const [renderNewTag, setRenderNewTag] = useState(false)

  const canCreate = useMemo(
    () =>
      policy.isAllowed("access_profile:tag_create", {
        target: { scoped_domain_name: scope.domain },
      }),
    [scope.domain]
  )

  const onCreateClick = () => {
    setShowNewForm(true)
    setRenderNewTag(true)
  }

  const onCollapseExited = () => {
    setRenderNewTag(false)
  }

  // remove services without tags
  const displayItems = useMemo(
    () =>
      Object.keys(items).reduce((object, serviceKey) => {
        if (items[serviceKey].tags.length > 0) {
          object[serviceKey] = items[serviceKey]
        }
        return object
      }, {}),
    [items]
  )

  const onCloseNewTag = ({ reload }) => {
    if (reload) {
      reloadTags()
    }
    setShowNewForm(false)
  }

  return (
    <>
      <div className="toolbar access-profiles-toolbar">
        <span className="capitalize">{profileKey}</span>
        <div className="main-buttons">
          {!showNewForm && (
            <SmartLink
              onClick={onCreateClick}
              style="primary"
              size="small"
              isAllowed={canCreate}
              notAllowedText="Not allowed to add new access profiles. Please check with your administrator."
            >
              New
            </SmartLink>
          )}
        </div>
      </div>

      {/* lets create a new form state on open new tag form */}
      <Collapse in={showNewForm} onExited={onCollapseExited}>
        <div className="container-to-work-collapse">
          {renderNewTag && (
            <FormStateProvider>
              <NewTag profileKey={profileKey} onClose={onCloseNewTag} />
            </FormStateProvider>
          )}
        </div>
      </Collapse>

      {displayItems && Object.keys(displayItems).length > 0 ? (
        Object.keys(displayItems).map((serviceKey, i) => (
          <ServiceAction
            key={serviceKey}
            serviceKey={serviceKey}
            serviceAttr={items[serviceKey]}
          />
        ))
      ) : (
        <div className="service">
          <div className="service-name empty-service">
            No access profiles found.
          </div>
        </div>
      )}
    </>
  )
}

export default AccessProfileItem
