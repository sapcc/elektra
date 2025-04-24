import React from "react"
import { useEffect } from "react"
import { Badge, Stack, Icon } from "@cloudoperators/juno-ui-components"

const ExpireDate = ({ item, setExpired, expired }) => {
  const [willExpire, setWillExpire] = React.useState(false)
  const [expiredDate, setExpiredDate] = React.useState(null)

  useEffect(() => {
    if (item.expires_at && item.expires_at !== "Unlimited") {
      const expriresAt = new Date(item.expires_at)
      //console.log("expiresAt", expriresAt)
      const currentDate = new Date()
      //console.log("currentDate", currentDate)

      let diffInSeconds = (expriresAt.getTime() - currentDate.getTime()) / 1000
      if (diffInSeconds > 0 && diffInSeconds < 60 * 60 * 24 * 7) {
        //console.log("will expire in less than 7 days")
        setWillExpire(true)
        setExpired(false)
      } else if (diffInSeconds < 0) {
        setExpired(true)
        setWillExpire(false)
      } else {
        setWillExpire(false)
        setExpired(false)
      }
      setExpiredDate(
        expriresAt.toLocaleDateString("en-US", {
          month: "long",
          day: "numeric",
          year: "numeric",
        })
      )
    } else {
      //console.log("expiresAt is not set or is Unlimited")
      setExpiredDate("Unlimited")
      setWillExpire(false)
      setExpired(false)
    }
    //console.log("expiredDate", expiredDate)
  }, [item])

  return (
    <div>
      <Stack direction="horizontal" gap="1">
        <div className={expired ? "tw-text-theme-light" : ""}>{expiredDate}</div>
        {expired ? (
          <Badge variant="warning" text="expired" />
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
