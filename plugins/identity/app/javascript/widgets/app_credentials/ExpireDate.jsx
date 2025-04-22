import React from "react"
import { Badge, Stack } from "@cloudoperators/juno-ui-components"

const ExpireDate = ({ item }) => {
  let expired = false
  let expiredDate = null
  if (item.expires_at && item.expires_at !== "Unlimited") {
    const expriresAt = new Date(item.expires_at)
    //console.log("expiresAt", expriresAt)
    const currentDate = new Date()
    //console.log("currentDate", currentDate)
    if (currentDate > expriresAt) {
      expired = true
    }
    expiredDate = expriresAt.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
      year: "numeric",
    })
  } else {
    //console.log("expiresAt is not set or is Unlimited")
    expiredDate = "Unlimited"
  }

  return (
    <div>
      {expired ? (
        <Stack direction="horizontal" gap="1">
          <Badge variant="warning" icon="warning">
            Expired
          </Badge>
          <Badge variant="danger" icon="info">
            {expiredDate}
          </Badge>
        </Stack>
      ) : (
        <Stack direction="horizontal" gap="1">
          <Badge variant="success" icon="success">
            Active
          </Badge>
          {expiredDate === "Unlimited" ? (
            <Badge variant="warning" icon="info">
              Unlimited
            </Badge>
          ) : (
            <Badge variant="success" icon="success">
              {expiredDate}
            </Badge>
          )}
        </Stack>
      )}
    </div>
  )
}
export default ExpireDate
