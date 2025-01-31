import essentialStyles from "./tailwind.scss?inline"

import "./core/jquery"
import "jquery-ujs"
import "bootstrap"
import "./core/dialogs"
import "./core/global_notifications"
import "./core/avatar_loader"

const styles = document.createElement("style")
styles.setAttribute("type", "text/css")
styles.setAttribute("data-name", "essentials")
styles.textContent = essentialStyles
document.head.appendChild(styles)
