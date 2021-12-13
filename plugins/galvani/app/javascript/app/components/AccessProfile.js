import React from "react"
import AccessService from "./AccessService"
import { policy } from "policy"
import SmartLink from "./shared/SmartLink"

const AccessProfile = ({ profileName, items }) => {
  const canCreate = true

  const onCreateClick = () => {}

  return (
    <div>
      <h4>{profileName}</h4>

      <div className="toolbar searchToolbar">
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
            Object.keys(items).map((serviceKey, i) => (
              <AccessService
                key={i}
                serviceName={serviceKey}
                description={items[serviceKey].description}
                items={items[serviceKey].items}
              />
            ))}
        </tbody>
      </table>
    </div>
  )
}

export default AccessProfile
