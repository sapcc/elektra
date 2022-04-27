import { createWidget } from "lib/widget"
import * as reducers from "./reducers"
import App from "./application"

createWidget(null, { html: { class: "flex-body" } }).then((widget) => {
  const foundScope = window.location.pathname.match(
    /\/([^\/]+)\/([^\/|\?|&]+)/i
  )

  // prevent baseURL to contain cc-tools as project on domain scoped urls
  if (foundScope && foundScope[2] == "cc-tools") {
    widget.configureAjaxHelper({ baseURL: `/${foundScope[1]}` })
  } else widget.configureAjaxHelper()

  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
