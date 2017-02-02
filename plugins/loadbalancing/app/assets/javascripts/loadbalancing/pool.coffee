
$(document).on 'modal:contentUpdated', (e) ->

  $form = $('form[id=pool_form]')

  $form.find('.form-group.pool_session_persistence_type select').change () ->
    value = $(this).find(":selected").val()
    if value == 'APP_COOKIE'
      $form.find(".form-group.pool_session_persistence_cookie_name").removeClass('hidden')
      $form.find(".form-group.pool_session_persistence_cookie_name").removeClass('disabled')
    else
      $form.find(".form-group.pool_session_persistence_cookie_name").addClass('hidden')
      $form.find(".form-group.pool_session_persistence_cookie_name").addClass('disabled')

  # determine corresponding protocol for listener selection
  $form.find('.form-group.pool_listener_id select').change () ->
    listener_id = $(this).find(":selected").val()
    select = $form.find('.form-group.pool_protocol select')
    select.empty()
    if listener_id != ''
      $.each protodata, (key, value) ->
        if key == listener_id
          select.append('<option value=' + value + '>' + value + '</option>')
    else
      $.each ['TCP', 'HTTP', 'HTTPS'], (index, value) ->
        select.append('<option value=' + value + '>' + value + '</option>')