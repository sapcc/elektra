/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import JSONEditor from "jsoneditor"

window.init_json_editor =
  window.init_json_editor ||
  function () {
    if ($("#jsoneditor").length) {
      let content = ""
      if ($("#jsoneditor").data("content-id")) {
        try {
          content = JSON.parse(window.eval($("#jsoneditor").data("content-id")))
        } catch (err) {
          content = window.eval($("#jsoneditor").data("content-id"))
        }
      } else {
        content = $("#jsoneditor").data("content")
      }
      const options = {
        mode: $("#jsoneditor").data("mode"),
        // eslint-disable-next-line no-unused-vars
        onChange(event) {
          window
            .eval($("#jsoneditor").data("on-change-update-field"))
            .val(editor.getText())
        },
      }

      // build the editor
      if (
        !(
          $("#jsoneditor").data("mode") === "view" &&
          (jQuery.type(content) === "undefined" || content === "")
        )
      ) {
        var editor = new JSONEditor(
          document.getElementById("jsoneditor"),
          options,
          content
        )

        // add resize button
        $("#jsoneditor .jsoneditor .jsoneditor-menu").append(
          "<a id='jsoneditor-resize' class='jsoneditor-poweredBy'><i class='fa fa-expand'></i><i class='fa fa-compress hide'></i></a>"
        )
        const resizeButton = $("#jsoneditor-resize")
        return resizeButton.on("click", function (e) {
          e.stopPropagation()
          e.preventDefault()
          if (resizeButton.find(".fa-expand").hasClass("hide")) {
            resizeButton.find(".fa-expand").removeClass("hide")
            resizeButton.find(".fa-compress").addClass("hide")
            $("#jsoneditor .jsoneditor").removeClass("fullsize")
            if ($.isFunction(editor.resize)) {
              return editor.resize()
            }
          } else {
            resizeButton.find(".fa-expand").addClass("hide")
            resizeButton.find(".fa-compress").removeClass("hide")
            $("#jsoneditor .jsoneditor").addClass("fullsize")
            if ($.isFunction(editor.resize)) {
              return editor.resize()
            }
          }
        })
      }
    }
  }

$(function () {
  // add handler to the show modal event
  $(document).on("modal:contentUpdated", init_json_editor)

  // init json editor in case not in a modal
  return init_json_editor()
})

export default init_json_editor
