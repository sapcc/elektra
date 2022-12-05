/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
$(function () {
  $("#inquiry-kind-filter").change(function () {
    // Get the id for the container we want to update
    const container_id = $(this).attr("data-container-id")

    // Parse parameters from update url (using the ba-bbq lib)
    const inquiries_container = $(`#${container_id} .inquiries-container`)
    const update_path = inquiries_container.attr("data-update-path")
    const params = $.deparam.querystring(update_path)

    // Set new filter according to selection
    params["filter"]["kind"] = $(this).val()

    // Enforce first page (if user was on a later page we need to jump them back to page 1 in case the filtered list is less than one page)
    params["page"] = 1

    // Save new update url
    inquiries_container.attr(
      "data-update-path",
      $.param.querystring(update_path, params)
    )

    // use visibility rather than display for this spinner so that the browser calculates the layout correctly
    $(".inquiries-filter.spinner").css("visibility", "visible")

    // Trigger update
    return PollingService.update("request")
  })

  $("body").on("polling:update_complete", function () {
    // hide all spinners
    $(".inquiries.spinner").hide()
    $(".inquiries-filter.spinner").css("visibility", "hidden")
  })
})
