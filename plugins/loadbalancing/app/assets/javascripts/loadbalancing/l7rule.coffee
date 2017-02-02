$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[id=l7rule_form]')

  $form.find('.form-group.l7rule_type select').change () ->
    value = $(this).find(":selected").val()
    if value=='HEADER' or value=='COOKIE'
      $form.find(".form-group.l7rule_key").removeClass('hidden')
    else
      $form.find(".form-group.l7rule_key").addClass('hidden')