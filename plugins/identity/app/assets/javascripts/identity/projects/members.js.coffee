formState= (form) ->
  state = ''
  # add 1 to state if checkbox is checked and 0 else
  $(form).find('select[data-roles-select] option').each () ->
    state += $(this).attr('value')+($(this).is(':selected') ? 1 : 0)
  state

multiselect=(elementsSelector) ->
  $(elementsSelector).multiselect({
    includeSelectAllOption: true,
    buttonText: (options, select) ->
      # options are selected checkboxes in role select
      # select is the form select.
      $tr = $(select).closest('tr')
      # all available labels
      availableLabels = []
      $(select).find('option').each () -> availableLabels.push($(this).text())
      #console.log("availableLabels ", availableLabels)

      # selected labels
      labels = []
      # add all selected options to labels
      options.each () -> labels.push($(this).text())
      $display = $(select).closest('tr').find('[data-roles-display]')
      # current selected roles
      currentRoles = $display.data('roles-current')

      # valuesToRemove = currentRoles - labels
      valuesToRemove = currentRoles.filter (x) ->
        #console.log(x, labels.indexOf(x),availableLabels.indexOf(x))
        #return ((labels.indexOf(x) < 0) and !(availableLabels.indexOf(x) < 0))

        return (availableLabels.indexOf(x) >= 0) and (labels.indexOf(x) < 0)
      # valuesToAdd = labels - currentRoles
      valuesToAdd = labels.filter (x) -> return currentRoles.indexOf(x) < 0

      newLabels = $(currentRoles).not(valuesToAdd).not(valuesToRemove).toArray()
      newLabels.push '<b>'+value+'</b>' for value in valuesToAdd
      newLabels.push '<s>'+value+'</s>' for value in valuesToRemove
      newLabels = newLabels.sort (a, b) -> return (a.replace('<b>','').replace('<s>','')>b.replace('<b>','').replace('<s>',''))


      if newLabels.length==0
        $display.html "No roles assigned yet!"
        $tr.addClass('danger')
      else
        label = newLabels.join(', ')

        if valuesToAdd.length==0 and newLabels.length==valuesToRemove.length
          $tr.addClass('danger')
          label += " <span class='info-text'>(click save to remove this member from the list)</span>"
        else if valuesToAdd.length>0 or valuesToRemove.length>0
          $tr.addClass('info')
          label += " <span class='info-text'>(click save to activate the changes)</span>"
        else
          $tr.removeClass('danger info')
        $display.html label

      # if newLabels.length>0
      #   $display.html newLabels.join(', ')
      # else
      #   $display.html "No roles assigned yet!"

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
      $form.find('input[type="submit"], .cancel.stash').removeClass('hidden').show('fade')
      $(this).closest('tr').removeClass('danger')
    else
      $form.find('input[type="submit"], .cancel.stash').hide('fade')

  # update current state if new elements are added to form
  $form.on 'DOMNodeInserted', (e) ->
    if e.target.nodeName=='TR'
      multiselect($(e.target).find('select[data-roles-select]'))
    # console.log('DOMNodeInserted', e.target)
      $form.currentState = formState($form)
      $form.find('.cancel.stash').removeClass('hidden stash').show('fade')

  # initialize current select dom elements
  multiselect($form.find('select[data-roles-select]'))
