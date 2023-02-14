/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const initAutoDismissibleFlash = () =>
  // dismiss just info and success flash messages
  setTimeout(
    () => $(".alert.auto-dismissible, .alert.auto-dismissible").fadeOut("fast"),
    6000
  )

$(function () {
  // close dismissible and auto-dismissible flashes
  $(document).on("click", ".alert .close", function () {
    $(this).parent().attr("aria-expanded", "false")
    return $(this).parent().fadeOut("fast")
  })

  // add handler to init dismissible flashes on loaded modals
  $(document).on("modal:contentUpdated", initAutoDismissibleFlash)

  // init dismissible flahses
  initAutoDismissibleFlash()

  return (window.initAutoDismissibleFlash = initAutoDismissibleFlash)
})
