/* eslint-disable no-undef */
import "jsoneditor"

initJsonEditor = () => {
  $("#jsoneditor").data("content-id")
}

$(document).on("modal:contentUpdated", initJsonEditor)
$(document).ready(initJsonEditor)
