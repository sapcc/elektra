$ ->
  $(document).on('click', '.alert .close', ->
    $(this).parent().attr('aria-expanded', 'false')
    $(this).parent().fadeOut('fast')
  )

  setTimeout(
    ->
      $('.alert.alert-info.alert-dismissible, .alert.alert-success.alert-dismissible').fadeOut('fast')
    6000
  )
