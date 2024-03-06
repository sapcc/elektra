import React from "react"
import { createRoot } from "react-dom/client"
import { Carousel, Alert } from "react-bootstrap"

const GlobalNotifications = () => {
  const [notifications, setNotifications] = React.useState([])

  const visibleNotifications = React.useMemo(() => {
    return notifications.filter((notification) => {
      if (!notification.start || !notification.end) return true
      if (notification.start)
        console.log(
          notification.start,
          new Date(notification.start),
          Date.now() >= new Date(notification.start)
        )
      if (notification.start && Date.now() >= new Date(notification.start))
        return true
      if (notification.end && Date.now() <= new Date(notification.end))
        return true
    })
  }, [notifications])

  React.useLayoutEffect(() => {
    if (visibleNotifications?.length > 0)
      document.body.classList.add("has-global-notifications")
    else document.body.classList.remove("has-global-notifications")
    return () => document.body.classList.remove("has-global-notifications")
  }, [visibleNotifications])

  React.useEffect(() => {
    const connect = (options) => {
      const eventSource = new EventSource("/system/sse")

      console.log("Global Notifications: SSE connected")
      eventSource.addEventListener("message", (event) => {
        const data = JSON.parse(event.data)
        //console.log("Global Notifications: New Notification", data)
        setNotifications(data?.message || [])
      })

      eventSource.addEventListener("error", (event) => {
        if (event.eventPhase === EventSource.CLOSED) {
          eventSource.close()
          console.log("Global Notifications: Event Source Closed")
          if (options.retry) {
            setTimeout(() => {
              console.log("Global Notifications: Reconnecting...")
              connect({ retry: options.retry })
            }, options.retry)
          }
        }
      })
      return eventSource.close
    }

    const close = connect({ retry: 30000 })
    return close
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
        <Carousel interval={null} indicators={false}>
          {visibleNotifications.map((notification, index) => (
            <Carousel.Item key={index}>
              <Alert bsStyle={notification.type || "info"}>
                <h4>{notification.title}</h4>
                <p>{notification.description}</p>
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
