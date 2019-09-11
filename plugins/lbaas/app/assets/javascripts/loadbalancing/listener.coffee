$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[id=listener_form]')

  $form.find('.form-group.listener_protocol select').change () ->
    value = $(this).find(":selected").val()
    if value=='TERMINATED_HTTPS'
      $form.find(".form-group.listener_default_tls_container_ref").removeClass('hidden')
      $form.find(".form-group.listener_sni_container_refs").removeClass('hidden')
    else
      $form.find(".form-group.listener_default_tls_container_ref").addClass('hidden')
      $form.find(".form-group.listener_sni_container_refs").addClass('hidden')