$.fn.loadbalancerState = (options = {}) ->
  path = $(this).data('update-loadbalancer-state')
  return unless path

  state = $(this)
  state.attr('data-toggle','tooltip').attr('data-placement','top')
  state.tooltip(title: () -> state.data('title'))

  istate = $(this).data('initial-loadbalancer-state')
  renderState(state, istate)

  getState(state, istate, path)

getState = (state, istate, path) ->
  # polling service needed for session timeouts
  $.get(path+'?do_not_redirect=true').done((data,status,xhr) ->
    redirectTo = xhr.getResponseHeader('Location')
    if redirectTo
      # redirect url is equal to auth path
      if redirectTo.indexOf('/auth/login/')>-1
        # just reload to avoid redirect to a no layout page after login
        window.location.reload()
      else
        # redirect to the redirectTo url
        window.location = redirectTo
    else
      renderState(state, data.provisioning_status)
    return
  ).always ->
    setTimeout((() -> getState(state, istate, path)), 10000)
    return
  return

renderState = (state, pstate) ->
  $status = $('<span class="label">' + pstate + '</span>')
  if pstate == 'ACTIVE'
    $status.addClass('label-success')
    state.data('title', 'Configuration of a Load Balancer in state ACTIVE can be changed')
  else if pstate == 'ERROR'
    $status.addClass('label-danger')
    state.data('title', 'Configuration of the Load Balancer is inconsistent. Undo the last changes to make it ACTIVE again')
  else if pstate == 'UNKNOWN'
    $status.addClass('label-info')
    state.data('title', 'The last request for the Load Balancer status did not succeed. Status will get updated soon.')
  else
    $status.addClass('label-warning')
    state.data('title', 'Configuration changes are in progress. Please DO NOT any changes to the Load Balancer until it is in state ACTIVE again')
  state.html($status)
