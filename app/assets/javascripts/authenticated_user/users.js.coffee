$(document).on 'ready page:load', ->
  $("#accept_tos").click -> $("#register-button").prop('disabled', not $(this).prop('checked') )
