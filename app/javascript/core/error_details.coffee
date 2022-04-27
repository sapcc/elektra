window.init_error_details= () ->
  $('[data-toggle="show-error-details"]').on 'click', show_error_details

window.show_error_details= (e) ->
  e.stopPropagation()
  e.preventDefault()

  if $(".error-details-area").hasClass('hide')
    $(".error-details-area").removeClass('hide')
  else
    $(".error-details-area").addClass('hide')

$ ->
  # init show error details
  $(document).on('modal:contentUpdated', init_error_details)

  # init in case the content is not in modal
  init_error_details()