/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
window.init_error_details = () =>
  $('[data-toggle="show-error-details"]').on("click", show_error_details)

window.show_error_details = function (e) {
  e.stopPropagation()
  e.preventDefault()

  if ($(".error-details-area").hasClass("hide")) {
    return $(".error-details-area").removeClass("hide")
  } else {
    return $(".error-details-area").addClass("hide")
  }
}

$(function () {
  // init show error details
  $(document).on("modal:contentUpdated", init_error_details)

  // init in case the content is not in modal
  return init_error_details()
})
