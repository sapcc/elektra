/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(() =>
  $("#capabilities_btn").on("inserted.bs.popover", (e) =>
    $('[data-trigger="webconsole:open"]').click(function (e) {
      e.preventDefault()
      // ensure all triggers get the active class (also the ones that haven't been clicked)
      const trigger = $("[data-trigger='webconsole:open']")
      if (!trigger.hasClass("active")) {
        trigger.addClass("active")
      }

      return WebconsoleContainer.open()
    })
  )
)
