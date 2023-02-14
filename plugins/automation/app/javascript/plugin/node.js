var close_popover,
  init_history_popover,
  init_job_popover,
  job_popover_close_other_popovers_handler,
  job_popover_matcher,
  job_popover_outside_click_handler

job_popover_matcher = '[data-toggle="popover"][data-popover-type="job-history"]'

init_history_popover = function () {
  return init_job_popover()
}

init_job_popover = function () {
  console.log("init_job_popover")

  $(job_popover_matcher).popover({
    placement: "top",
    html: true,
    container: ".js-nodes-table",
  })
  $(job_popover_matcher).on("click", job_popover_close_other_popovers_handler)
  $(job_popover_matcher).on("shown.bs.popover", function () {
    return $(".js-close-popover").on("click", close_popover)
  })
  $("html").unbind("click", job_popover_outside_click_handler)
  if ($(job_popover_matcher).length > 0) {
    return $("html").bind("click", job_popover_outside_click_handler)
  }
}

close_popover = function () {
  return $(job_popover_matcher).popover("hide")
}

job_popover_close_other_popovers_handler = function (e) {
  e.stopPropagation()
  e.preventDefault()
  return $(job_popover_matcher).not(this).popover("hide")
}

job_popover_outside_click_handler = function (e) {
  if (
    $(e.target).data("popover-type") !== "job-history" &&
    $(e.target).parents(".popover.in").length === 0
  ) {
    return close_popover()
  }
}

$(function () {
  $(document).on("polling:update_complete", init_history_popover)
  return init_job_popover()
})
