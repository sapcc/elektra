
$(document).on 'modal:contentUpdated', (e) ->

  $form = $('form[id=pool_form]')
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

  $form.find('.form-group.pool_tls_enabled').change () ->
    changeTlsEnabled()

  # set persistence type on init (needed when default pool is created)
  changePersistenceType($form.find('.form-group.pool_protocol select'))

# change persistence selection box based on protocol
changePersistenceType=(poolSelect) ->
  $form = $('form[id=pool_form]')
  protocol = $(poolSelect).find(":selected").val()
  persistence_select = $form.find('.form-group.pool_session_persistence_type select')
  persistence_select_val = persistence_select.find(":selected").val()
  persistence_select.empty()
  if protocol == 'TCP'
    session_persistence_type = [' ', 'SOURCE_IP']
  else
    session_persistence_type = [' ', 'SOURCE_IP', 'HTTP_COOKIE', 'APP_COOKIE']
  $.each session_persistence_type, (key, value) ->
    if value == persistence_select_val
      persistence_select.append('<option value=' + value + ' selected>' + value + '</option>')
    else
      persistence_select.append('<option value=' + value + '>' + value + '</option>')
  changeAppCookie($form.find('.form-group.pool_session_persistence_type select'))

# disable app_cookie name
changeAppCookie=(persistence_type) ->
  $form = $('form[id=pool_form]')
  value = $(persistence_type).find(":selected").val()
  if value == 'APP_COOKIE'
    $form.find(".form-group.pool_session_persistence_cookie_name").removeClass('hidden')
    $form.find(".form-group.pool_session_persistence_cookie_name").removeClass('disabled')
  else
    $form.find(".form-group.pool_session_persistence_cookie_name").addClass('hidden')
    $form.find(".form-group.pool_session_persistence_cookie_name").addClass('disabled')

# disable app_cookie name
changeTlsEnabled=() ->
  $form = $('form[id=pool_form]')
  checked = $('#pool_tls_enabled').is(':checked')
  if checked == true
    $form.find(".form-group.pool_tls_container_ref").removeClass('hidden')
    $form.find(".form-group.pool_tls_container_ref").removeClass('disabled')
    $form.find(".form-group.pool_ca_tls_container_ref").removeClass('hidden')
    $form.find(".form-group.pool_ca_tls_container_ref").removeClass('disabled')
  else
    $form.find(".form-group.pool_tls_container_ref").addClass('hidden')
    $form.find(".form-group.pool_tls_container_ref").addClass('disabled')
    $form.find(".form-group.pool_ca_tls_container_ref").addClass('hidden')
    $form.find(".form-group.pool_ca_tls_container_ref").addClass('disabled')

$(document).on 'click', '.pool-member-remove', (e) ->
  e.preventDefault()
  target = $(this).attr('data-target')
  $(target).remove()