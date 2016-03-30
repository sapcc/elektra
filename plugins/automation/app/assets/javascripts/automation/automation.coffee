@init_tag_editor_inputs= () ->
  $('textarea[data-toggle="tagEditor"][data-tageditor-type="key-value"]').each ->
    $(this).tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter key value pairs' })
  $('textarea[data-toggle="tagEditor"][data-tageditor-type="tag"]').each ->
    $(this).tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter tags', keyValueEntries: false })

@switch_automation_type=(event) ->
  value = event.target.value
  if value == 'chef'
    $('#chef-automation').removeClass('hide')
    $('#script-automation').addClass('hide')
  else if value == 'script'
    $('#script-automation').removeClass('hide')
    $('#chef-automation').addClass('hide')

@run_automation_link=(event) ->
  agent_id = $(event.target).data('agent-id')
  spinner = $('i.loading-spinner-section[data-agent-id=' + agent_id + ']')
  spinner.removeClass('hide')
  btn_group = $('.btn-group[data-agent-id=' + agent_id + ']')
  btn_group.addClass('hide')
  $.ajax
    url: $(event.target).data('link'),
    dataType: 'html',
    success: ( data, textStatus, jqXHR ) ->
      $(".flashes").append(data)
    error: () ->
      $(".flashes").append(data)
    complete: () ->
      spinner.addClass('hide')
      btn_group.removeClass('hide')


$ ->
  # add handler to the show modal event
  $(document).on('modal:contentUpdated', init_tag_editor_inputs)

  # add handler to the show modal event
  # $(document).on('modal:contentUpdated', init_hint_popover)

  # add handler to the automation type select
  $(document).on 'change','select[data-toggle="automationSwitch"]', switch_automation_type

  $(document).on 'click','a[data-toggle="run_automation_link"]', run_automation_link

  # init in case the content is not in modal
  init_tag_editor_inputs()
  # init_hint_popover()