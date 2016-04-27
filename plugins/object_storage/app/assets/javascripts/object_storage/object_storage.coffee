$ ->
  $('#capabilities_btn').on 'inserted.bs.popover', (e) ->
    $('[data-trigger="webconsole:open"]').click (e) ->
      e.preventDefault()
      # ensure all triggers get the active class (also the ones that haven't been clicked)
      trigger = $("[data-trigger='webconsole:open']")
      unless trigger.hasClass('active')
        trigger.addClass("active")

      WebconsoleContainer.open()
