import React, { useMemo } from "react"
import AccessService from "./AccessService"
import { policy } from "policy"
import SmartLink from "./shared/SmartLink"

const AccessProfile = ({ profileName, items }) => {
  const canCreate = true

  const onCreateClick = () => {}

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
    <div>
      <div className="toolbar searchToolbar">
        <span>{profileName}</span>
        <div className="main-buttons">
          <SmartLink
            onClick={onCreateClick}
            style="primary"
            size="small"
            isAllowed={canCreate}
            notAllowedText="Not allowed to create. Please check with your administrator."
          >
            New Access Profile
          </SmartLink>
        </div>
      </div>

      <table className="table datatable">
        <tbody>
          {items &&
            Object.keys(displayItems).map((serviceKey, i) => (
              <AccessService
                key={i}
                serviceKey={serviceKey}
                serviceAttr={items[serviceKey]}
              />
            ))}
        </tbody>
      </table>
    </div>
  )
}

export default AccessProfile
