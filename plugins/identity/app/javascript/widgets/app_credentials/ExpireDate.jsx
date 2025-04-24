import React from "react"
import { Badge, Stack, Icon } from "@cloudoperators/juno-ui-components"

const ExpireDate = ({ item }) => {
  let expired = false
  let willExpire = false
  let expiredDate = null
  if (item.expires_at && item.expires_at !== "Unlimited") {
    const expriresAt = new Date(item.expires_at)
    //console.log("expiresAt", expriresAt)
    const currentDate = new Date()
    //console.log("currentDate", currentDate)

    let diffInSeconds = (expriresAt.getTime() - currentDate.getTime()) / 1000
    if (diffInSeconds > 0 && diffInSeconds < 60 * 60 * 24 * 7) {
      //console.log("will expire in less than 7 days")
      willExpire = true
    } else if (diffInSeconds < 0) {
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
      <Stack direction="horizontal" gap="1">
        <div>{expiredDate}</div>
        {expired ? (
          <Badge className="tw-text-theme-light" variant="warning" text="expired" />
        ) : (
          <span>
            {willExpire ? (
              <Icon color="tw-text-theme-warning" icon="warning" title="will expire in less than 7 days" />
            ) : (
              ""
            )}
          </span>
        )}
      </Stack>
    </div>
  )
}
export default ExpireDate
