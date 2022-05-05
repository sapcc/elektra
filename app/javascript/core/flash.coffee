initAutoDismissibleFlash= () ->
  # dismiss just info and success flash messages
  setTimeout(
    ->
      $('.alert.auto-dismissible, .alert.auto-dismissible').fadeOut('fast')
    6000
  )

$ ->
  # close dismissible and auto-dismissible flashes
  $(document).on('click', '.alert .close', ->
    $(this).parent().attr('aria-expanded', 'false')
    $(this).parent().fadeOut('fast')
  )

  # add handler to init dismissible flashes on loaded modals
  $(document).on('modal:contentUpdated', initAutoDismissibleFlash)

  # init dismissible flahses
  initAutoDismissibleFlash()

  window.initAutoDismissibleFlash = initAutoDismissibleFlash
