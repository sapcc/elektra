$.fn.updateState = (state) ->
  if state
    xstate = state
  else
    xstate = 'UNKNOWN'
  switch xstate
    when 'ACTIVE'
      className = 'label-success'
      title = 'Configuration changes possible'
    when 'ONLINE'
      className = 'label-success'
      title = 'Object is responding'
    when 'DEGRADED'
      className = 'label-warning-greyscale'
      title = 'Some Objects are not responding'
    when 'ERROR'
      className = 'label-danger'
      title = 'Object is not working/deployed properly'
    when 'OFFLINE'
      className = 'label-danger-greyscale'
      title = 'Object is not responding'
    else
      className = 'label-info'
      title = ''

  if xstate.match(/PENDING_/)
    className = 'label-warning'
    title = 'Configuration change in progress'

  $(this).attr('data-toggle','tooltip').attr('data-placement','top')
  $(this).tooltip(title: () -> $(this).data('title'))
  $(this).data('title', title)
  $(this).text(xstate).removeClass().addClass('label').addClass(className)