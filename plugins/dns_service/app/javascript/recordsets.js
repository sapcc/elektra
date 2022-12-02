/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(document).on("modal:contentUpdated", function () {
  $("select[data-dynamic-label]").change(function () {
    const value = $(this).val()
    const labelValues = $(this).data(value)
    const $target = $($(this).data("dynamicLabel"))
    const $label = $(`label[for="${$target.attr("id")}"]`)

    const newLabel =
      $label.find("abbr").length > 0
        ? `<abbr title="required">*</abbr>${labelValues.label}`
        : labelValues.label

    $label.html(newLabel)

    // replace input with textarea
    if ($target.prop("tagName") === "INPUT" && labelValues.type === "text") {
      const $textarea = $("<textarea></textarea>")
      $textarea.prop("name", $target.prop("name"))
      $textarea.prop("id", $target.prop("id"))
      $textarea.prop("class", $target.prop("class"))
      return $target.replaceWith($textarea)
      // replace textarea with input
    } else if (
      $target.prop("tagName") === "TEXTAREA" &&
      labelValues.type !== "text"
    ) {
      const $input = $('<input type="text"></input>')
      $input.prop("name", $target.prop("name"))
      $input.prop("id", $target.prop("id"))
      $input.prop("class", $target.prop("class"))
      return $target.replaceWith($input)
    }
  })

  // recordset name input event handlers to allow users to create records for just the zone name
  $("#recordset-name-input").focus(function () {
    return $(this).parent().addClass("addon-active")
  })

  $("#recordset-name-input").blur(function () {
    return toggleZoneNameDisplay($(this))
  })

  return $("#recordset-name-input").keyup(function (e) {
    const keyCode = e.keyCode || e.which

    // ignore the tab key (in case user uses tab to focus the input we want the 'on focus' event handler to do its thing, not this one)
    if (keyCode !== 9) {
      return toggleZoneNameDisplay($(this))
    }
  })
})

var toggleZoneNameDisplay = function (target) {
  const value = target.val()
  if (value.length > 0) {
    return target.parent().addClass("addon-active")
  } else {
    return target.parent().removeClass("addon-active")
  }
}
