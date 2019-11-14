$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[id=listener_form]')

  $form.find('.form-group.listener_protocol select').change () ->
    value = $(this).find(":selected").val()
    if value == 'TERMINATED_HTTPS'
      $form.find(".form-group.listener_default_tls_container_ref").removeClass('hidden')
      $form.find(".form-group.listener_sni_container_refs").removeClass('hidden')
      $form.find(".form-group.listener_client_authentication").removeClass('hidden')
      $form.find(".form-group.listener_client_ca_tls_container_ref").removeClass('hidden')
    else
      $form.find(".form-group.listener_default_tls_container_ref").addClass('hidden')
      $form.find(".form-group.listener_sni_container_refs").addClass('hidden')
      $form.find(".form-group.listener_client_authentication").addClass('hidden')
      $form.find(".form-group.listener_client_ca_tls_container_ref").addClass('hidden')

    changeInsertHeaders(this)

  $form.find('.form-group.listener_client_authentication select').change () ->
    value = $(this).find(":selected").val()
    proto = $form.find('.form-group.listener_protocol select')
    value = $(this).find(":selected").val()

    if value == 'NONE' || value == ''
      $form.find(".form-group.listener_client_ca_tls_container_ref").addClass('hidden')
    else
      $form.find(".form-group.listener_client_ca_tls_container_ref").removeClass('hidden')


# change persistence selection box based on protocol
changeInsertHeaders=(listenerSelect) ->
  $form = $('form[id=listener_form]')
  protocol = $(listenerSelect).find(":selected").val()
  headers_select = $form.find('.form-group.listener_insert_headers select')
  headers_select_val = headers_select.find(":selected").val()
  headers_select.empty()
  if protocol == '' || protocol == 'TCP' || protocol == 'UDP'
    insert_headers = ['']
    $form.find('.form-group.listener_insert_headers').addClass('hidden')
  else
    $form.find('.form-group.listener_insert_headers').removeClass('hidden')
    if protocol == 'HTTP' || protocol == 'HTTPS'
      insert_headers = ['X-Forwarded-For', 'X-Forwarded-Port', 'X-Forwarded-Proto']
    else
      insert_headers = ['X-Forwarded-For', 'X-Forwarded-Port', 'X-Forwarded-Proto', 'X-SSL-Client-Verify', 'X-SSL-Client-Has-Cert', 'X-SSL-Client-DN', 'X-SSL-Client-CN', 'X-SSL-Issuer', 'X-SSL-Client-SHA1', 'X-SSL-Client-Not-Before', 'X-SSL-Client-Not-After']

  $.each insert_headers, (key, value) ->
    if value == headers_select_val
      headers_select.append('<option value=' + value + ' selected>' + value + '</option>')
    else
      headers_select.append('<option value=' + value + '>' + value + '</option>')