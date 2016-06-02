formState= (form) ->
  state = ''
  # add 1 to state if checkbox is checked and 0 else
  $(form).find('select[data-roles-select] option').each () -> 
    state += $(this).attr('value')+($(this).is(':selected') ? 1 : 0)
  state
  
multiselect=(elementsSelector) ->
  $(elementsSelector).multiselect({
    buttonText: (options, select) ->
      labels = []
      options.each () -> labels.push($(this).text())
      $display = $(select).closest('tr').find('[data-roles-display]')
      currentRoles = $display.data('roles-current')

      valuesToRemove = currentRoles.filter (x) -> return labels.indexOf(x) < 0
      valuesToAdd = labels.filter (x) -> return currentRoles.indexOf(x) < 0
      newLabels = $(currentRoles).not(valuesToAdd).not(valuesToRemove).toArray()
      newLabels.push '<b>'+value+'</b>' for value in valuesToAdd
      newLabels.push '<s>'+value+'</s>' for value in valuesToRemove
      newLabels = newLabels.sort (a, b) -> return (a.replace('<b>','').replace('<s>','')>b.replace('<b>','').replace('<s>',''))

      $display.html newLabels.join(', ')

      'Manage Roles'
  })   
  
$(document).ready ->
  # get form
  $form = $('form.role_assignments')
  # initialize current state of checked and unchecked chckboxes
  $form.currentState = formState($form)
  
  # show or hide save button if state of checkboxes has changed.
  $form.on 'change', 'select[data-roles-select]', () ->
    newState = formState($form)

    if $form.currentState!=newState
      $form.find('input[type="submit"]').removeClass('hidden').show('fade')
      $(this).closest('tr').removeClass('danger')
    else
      $form.find('input[type="submit"]').hide('fade')
  
  # update current state if new elements are added to form
  $form.on 'DOMNodeInserted', (e) ->
    if e.target.nodeName=='TR'
      multiselect($(e.target).find('select[data-roles-select]')) 
    # console.log('DOMNodeInserted', e.target)
    #$form.currentState = formState($form)
  
  # initialize current select dom elements
  multiselect($form.find('select[data-roles-select]'))    
