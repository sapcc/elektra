// The contents of this file are executed globally on every page load.
// see /app/javascript/packs/application.js for more infos!
import { createWidget } from "lib/widget"
import Modal from "./containers/modal"
import ModalLink from "./containers/modal_link"
import List from "./containers/list"
import * as reducers from "./reducers"

// console.log('This widget is always loaded')

const App = (props) => {
  if (props["data-react-auth-projects-link"])
    return <ModalLink iconClass={props["data-icon-class"]} />

  const listProps = {}
  for (let key in props) {
    const value = props[key]
    if (key.indexOf("data-") == 0 && typeof value !== "undefined")
      listProps[key.substring(5)] = value == "false" ? false : value
  }

  if (props["data-auth-projects-modal-container"])
    return <Modal {...listProps} />

  return <List {...listProps} />
}

$(() => {
  let authProjectsModalLinks = [
    ...document.querySelectorAll("[data-react-auth-projects-link]"),
  ]
  let authProjectContainers = [
    ...document.querySelectorAll("[data-react-auth-projects]"),
  ]

  let reactContainers = authProjectContainers.concat(authProjectsModalLinks)

  if (authProjectsModalLinks && authProjectsModalLinks.length > 0) {
    const modalContainer = document.createElement("div")
    modalContainer.setAttribute("data-auth-projects-modal-container", true)
    document.body.appendChild(modalContainer)
    reactContainers.push(modalContainer)
  }

  createWidget(null, {
    html: { class: "flex-body" },
    params: { flashescontainer: "custom" },
    containers: reactContainers,
  })
    .then((widget) => {
      widget.configureAjaxHelper()
      widget.setPolicy()
      widget.createStore(reducers)
      widget.render(App)
    })
    .catch((e) => console.log(e))
})
