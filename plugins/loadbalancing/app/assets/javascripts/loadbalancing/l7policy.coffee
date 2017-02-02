$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[id=l7policy_form]')

  $form.find('.form-group.l7policy_action select').change () ->
    value = $(this).find(":selected").val()
    if value=='REDIRECT_TO_POOL'
      $form.find(".form-group.l7policy_redirect_pool_id").removeClass('hidden')
      $form.find(".form-group.l7policy_redirect_url").addClass('hidden')
    else if value=='REDIRECT_TO_URL'
      $form.find(".form-group.l7policy_redirect_pool_id").addClass('hidden')
      $form.find(".form-group.l7policy_redirect_url").removeClass('hidden')
    else
      $form.find(".form-group.l7policy_redirect_pool_id").addClass('hidden')
      $form.find(".form-group.l7policy_redirect_url").addClass('hidden')