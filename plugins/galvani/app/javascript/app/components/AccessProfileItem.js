import React, { useMemo, useState } from "react"
import ServiceAction from "./ServiceAction"
import { policy } from "policy"
import SmartLink from "./shared/SmartLink"
import NewTag from "./NewTag"
import { FormStateProvider } from "./FormState"

const AccessProfileItem = ({ profileKey, items }) => {
  const [showNewForm, setShowNewForm] = useState(false)
  const canCreate = true
  const onCreateClick = () => {
    setShowNewForm(true)
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

  return (
    <>
      <div className="toolbar access-profiles-toolbar">
        <span className="capitalize">{profileKey}</span>
        <div className="main-buttons">
          <SmartLink
            onClick={onCreateClick}
            style="primary"
            size="small"
            disabled={showNewForm}
            isAllowed={canCreate}
            notAllowedText="Not allowed to add new access profiles. Please check with your administrator."
          >
            New
          </SmartLink>
        </div>
      </div>

      <FormStateProvider>
        <NewTag
          profileName={profileKey}
          show={showNewForm}
          cancelCallback={() => setShowNewForm(false)}
        />
      </FormStateProvider>

      {displayItems && Object.keys(displayItems).length > 0 ? (
        Object.keys(displayItems).map((serviceKey, i) => (
          <ServiceAction
            key={i}
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
