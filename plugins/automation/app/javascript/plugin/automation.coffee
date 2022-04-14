init_tag_editor_inputs= () ->
  $('textarea[data-toggle="tagEditor"][data-tageditor-name="environment"]').each ->
    $(this).tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter key value pairs', keyValueEntries: true, forceLowercase: false, maxLength: 255, delimiter: '¡' })
  $('textarea[data-toggle="tagEditor"][data-tageditor-name="arguments"]').each ->
    $(this).tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter tags', keyValueEntries: false, forceLowercase: false, maxLength: 255, delimiter: '¡' })
  $('textarea[data-toggle="tagEditor"][data-tageditor-name="runlist"]').each ->
    $(this).tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter tags', keyValueEntries: false, forceLowercase: false, maxLength: 255, delimiter: '¡' })
  $('textarea[data-toggle="tagEditor"][data-tageditor-name="tags"]').each ->
    $(this).tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter tags', keyValueEntries: true, forceLowercase: true, maxLength: 255, delimiter: '¡' })

switch_automation_type=(event) ->
  value = event.target.value
  if value == 'chef'
    $('#chef-automation').removeClass('hide')
    $('#script-automation').addClass('hide')
  else if value == 'script'
    $('#script-automation').removeClass('hide')
    $('#chef-automation').addClass('hide')

select_automation_instance=(event) ->
  value = event.target.value
  if value == 'external'
    $('.js-external-instance').removeClass('hide')
  else
    $('.js-external-instance').addClass('hide')

run_automation_link=(event) ->
  node_id = $(event.target).data('node-id')
  spinner = $('i.loading-spinner-section[data-node-id=' + node_id + ']')
  spinner.removeClass('hide')
  btn_group = $('.btn-group[data-node-id=' + node_id + ']')
  btn_group.addClass('hide')
  $.ajax
    url: $(event.target).data('link'),
    dataType: 'html',
    success: ( data, textStatus, jqXHR ) ->
      # do not auto dismiss the success alerts.
      if $(data).hasClass('flashes')
        $(".flashes").append($(data).contents())
      else
        $(".flashes").append(data)
    error: (request, status, error) ->
      $(".flashes").append(request.responseText)
    complete: () ->
      spinner.addClass('hide')
      btn_group.removeClass('hide')

update_submit_button=(event) ->
  submitButton = $('button[data-toggle="update_repository_credentials"]')
  if $(event.target).prop('checked')
    submitButton.attr("data-confirm","Are you sure you want to remove the repository credentials?")
    submitButton.attr("data-ok","Yes, remove it")
  else
    submitButton.removeAttr("data-confirm","Are you sure you want to remove the repository credentials?")
    submitButton.removeAttr("data-ok","Yes, remove it")

$ ->
  # add handler to the show modal event
  $(document).on('modal:contentUpdated', init_tag_editor_inputs)

  # add handler to the automation type select
  $(document).on 'change','select[data-toggle="automationSwitch"]', switch_automation_type

  $(document).on 'change','select[data-toggle="selectAutomationInstance"]', select_automation_instance

  $(document).on 'click','a[data-toggle="run_automation_link"]', run_automation_link

  $(document).on 'click','input[type="checkbox"][data-toggle="update_repository_credentials"]', update_submit_button

  # init in case the content is not in modal
  init_tag_editor_inputs()
