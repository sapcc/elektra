import "./cloud_admin"
import "./domain_admin"

// This is always executed on page load.
$(document).ready(function () {
  // show small loading spinner on active tab during ajax calls
  $(document).ajaxStart(function () {
    $(".loading-place").addClass("loading")
  })
  $(document).ajaxStop(function () {
    $(".loading-place").removeClass("loading")
  })
})
