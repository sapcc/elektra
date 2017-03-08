
$(document).on 'modal:contentUpdated', (e) ->

  $form = $('form[id=pool_form]')

  # change persistence selection box based on protocol
  changePersistenceType=(poolSelect) ->
    protocol = $(poolSelect).find(":selected").val()
    select = $form.find('.form-group.pool_session_persistence_type select')
    select.empty()
    if protocol == 'TCP'
      session_persistence_type = ['', 'SOURCE_IP']
    else
      session_persistence_type = ['', 'SOURCE_IP', 'HTTP_COOKIE', 'APP_COOKIE']
    $.each session_persistence_type, (key, value) ->
      select.append('<option value=' + value + '>' + value + '</option>')
    changeAppCookie($form.find('.form-group.pool_session_persistence_type select'))

  # disable app_cookie name
  changeAppCookie=(persistence_type) ->
    value = $(persistence_type).find(":selected").val()
    if value == 'APP_COOKIE'
      $form.find(".form-group.pool_session_persistence_cookie_name").removeClass('hidden')
      $form.find(".form-group.pool_session_persistence_cookie_name").removeClass('disabled')
    else
      $form.find(".form-group.pool_session_persistence_cookie_name").addClass('hidden')
      $form.find(".form-group.pool_session_persistence_cookie_name").addClass('disabled')

  $form.find('.form-group.pool_session_persistence_type select').change () ->
    changeAppCookie(this)

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
        select.append('<option value=' + value + '>' + value + '</option>')  # determine corresponding protocol for listener selection
    changePersistenceType($form.find('.form-group.pool_protocol select'))


  $form.find('.form-group.pool_protocol select').change () ->
    changePersistenceType(this)

  # set persistence type on init (needed when default pool is created)
  changePersistenceType($form.find('.form-group.pool_protocol select'))
