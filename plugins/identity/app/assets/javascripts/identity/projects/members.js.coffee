formState= (form) ->
  state = ''
  # add 1 to state if checkbox is checked and 0 else
  $(form).find('input[type="checkbox"]').each () -> state += (if $(this).is(':checked') then '1' else '0')
  state
  
$(document).ready ->
  # get form
  $form = $('form.role_assignments')
  # initialize current state of checked and unchecked chckboxes
  $form.currentState = formState($form)  
  # update current state if new elements are added to form
  $form.bind 'DOMNodeInserted', () -> $form.currentState = formState($form)
  
  # show or hide save button if state of checkboxes has changed.
  $form.on 'change', 'input[type="checkbox"]', () ->
    newState = formState($form)

    if $form.currentState!=newState
      $form.find('input[type="submit"]').removeClass('hidden').show('fade')
      $(this).closest('tr').removeClass('danger')
    else
      $form.find('input[type="submit"]').hide('fade')
