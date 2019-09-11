$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[id=healthmonitor_form]')

  $form.find('.form-group.healthmonitor_type select').change () ->
    value = $(this).find(":selected").val()
    if value == 'HTTP' || value == 'HTTPS'
      $form.find(".form-group.healthmonitor_http_method").removeClass('hidden')
      $form.find(".form-group.healthmonitor_expected_codes").removeClass('hidden')
      $form.find(".form-group.healthmonitor_url_path").removeClass('hidden')
    else
      $form.find(".form-group.healthmonitor_http_method").addClass('hidden')
      $form.find(".form-group.healthmonitor_expected_codes").addClass('hidden')
      $form.find(".form-group.healthmonitor_url_path").addClass('hidden')
