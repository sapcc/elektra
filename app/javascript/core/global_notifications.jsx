import React from "react"
import { createRoot } from "react-dom/client"
import { Carousel, Alert } from "react-bootstrap"

const GlobalNotifications = () => {
  const [notifications, setNotifications] = React.useState([])

  const visibleNotifications = React.useMemo(() => {
    return notifications.filter((notification) => {
      if (!notification.start && !notification.end) return true
      if (notification.start) {
        try {
          if (Date.now() >= Date.parse(notification.start)) return true
        } catch (e) {
          return false
        }
      }
      if (notification.end) {
        try {
          if (Date.now() <= Date.parse(notification.end)) return true
        } catch (e) {
          return false
        }
      }
    })
  }, [notifications])

  console.log("====", visibleNotifications)

  React.useLayoutEffect(() => {
    if (visibleNotifications?.length > 0)
      document.body?.classList?.add("has-global-notifications")
    else document.body?.classList?.remove("has-global-notifications")
    return () => document.body?.classList?.remove("has-global-notifications")
  }, [visibleNotifications])

  React.useEffect(() => {
    const load = async () => {
      console.log("fetching global notifications")
      const response = await fetch("/system/notifications")
      let data = await response.json()
      if (typeof data === "string") data = []

      setNotifications(data || [])
    }
    let timer = setInterval(load, 6 * 1000)
    load()
    return () => clearInterval(timer)
  }, [])

  if (visibleNotifications?.length === 0) return null

  return (
    <div className="global_notifications">
      {visibleNotifications?.length === 1 ? (
        <Alert bsStyle={visibleNotifications[0].type || "info"}>
          <h4>
            {visibleNotifications[0]?.title ||
              "Oh snap! You got a notification!"}
          </h4>
          <p>{visibleNotifications[0]?.description || ""}</p>
        </Alert>
      ) : (
        <Carousel interval={10000} indicators={false} controls={false}>
          {visibleNotifications.map((notification, index) => (
            <Carousel.Item key={index}>
              <Alert bsStyle={notification.type || "info"}>
                <div style={{ display: "flex" }}>
                  <div>
                    <i className={`fa fa-${notification.type || "info"}`} />
                  </div>
                  <div>
                    <b>{notification.title}</b> {notification.description}
                  </div>
                </div>
              </Alert>
            </Carousel.Item>
          ))}
        </Carousel>
      )}
    </div>
  )
}

const container = document.createElement("div")
const root = createRoot(container)
root.render(<GlobalNotifications />)

window.addEventListener("load", () => {
  document.body.prepend(container)
})
