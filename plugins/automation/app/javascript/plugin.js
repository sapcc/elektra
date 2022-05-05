import { AnsiUp } from "ansi-up"
import "./plugin/automation_search.coffee"
import "./plugin/automation.coffee"
import "./plugin/inline_form_node_tag.coffee"
import "./plugin/jquery.caret.min"
import "./plugin/jquery.tag-editor"
import "./plugin/node.coffee"

import "lib/jsoneditor.coffee"
window.$(document).ready(init_json_editor)

window.onload = function () {
  var ansi_up = new AnsiUp()

  var source = document.getElementById("logData")
  var output = document.getElementById("logDataAnsi")
  if (source && output) {
    output.innerHTML = ansi_up.ansi_to_html(source.innerHTML)
  }
}
