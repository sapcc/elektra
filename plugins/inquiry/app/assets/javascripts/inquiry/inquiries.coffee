$ ->
  $("#inquiry-kind-filter").change ->

    # Get the id for the container we want to update
    container_id = $(this).attr('data-container-id')

    # Parse parameters from update url (using the ba-bbq lib)
    inquiries_container = $('#' + container_id + ' .inquiries-container')
    update_path = inquiries_container.attr('data-update-path')
    params = $.deparam.querystring(update_path)

    # Set new filter according to selection
    params['filter']['kind'] = $(this).val();

    # Enforce first page (if user was on a later page we need to jump them back to page 1 in case the filtered list is less than one page)
    params['page'] = 1

    # Save new update url
    inquiries_container.attr('data-update-path', $.param.querystring( update_path, params ))

    # use visibility rather than display for this spinner so that the browser calculates the layout correctly
    $(".inquiries-filter.spinner").css("visibility", "visible")

    # Trigger update
    PollingService.update('request')


  $('body').on "polling:update_complete", ->
    # hide all spinners
    $(".inquiries.spinner").hide();
    $(".inquiries-filter.spinner").css("visibility", "hidden")
