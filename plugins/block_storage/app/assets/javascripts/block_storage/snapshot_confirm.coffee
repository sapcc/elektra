$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[id=form_snapshot]')

  $form.find('input[id=snapshot_confirmed]').change () ->
    value = $form.find('input[id=snapshot_confirmed]').is(":checked")
    if value==true
      $form.find(".snapshot_name").removeClass('hidden')
      $form.find(".snapshot_name").removeClass('disabled')
      $form.find(".snapshot_description").removeClass('hidden')
      $form.find(".snapshot_description").removeClass('disabled')
      $form.find('.buttons').find('button[id=create_button]').removeClass('disabled')
      $form.find('.buttons').find('button[id=create_button]').removeAttr('disabled')
    else
      $form.find(".snapshot_name").addClass('hidden')
      $form.find(".snapshot_name").addClass('disabled')
      $form.find(".snapshot_description").addClass('hidden')
      $form.find(".snapshot_description").addClass('disabled')
      $form.find('.buttons').find('button[id=create_button]').addClass('disabled')
      $form.find('.buttons').find('button[id=create_button]').attr('disabled', true)
