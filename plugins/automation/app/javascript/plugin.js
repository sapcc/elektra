import { AnsiUp } from "ansi-up"
import "./plugin/automation_search.js"
import "./plugin/automation.js"
import "./plugin/inline_form_node_tag.js"
import "./plugin/jquery.caret.min"
import "./plugin/jquery.tag-editor"
import "./plugin/node.js"

import init_json_editor from "lib/jsoneditor"
window.$(document).ready(init_json_editor)

window.onload = function () {
  var ansi_up = new AnsiUp()

  var source = document.getElementById("logData")
  var output = document.getElementById("logDataAnsi")
  if (source && output) {
    output.innerHTML = ansi_up.ansi_to_html(source.innerHTML)
  }
}
