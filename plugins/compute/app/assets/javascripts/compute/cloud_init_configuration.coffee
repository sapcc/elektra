userDataFieldId = '#server_user_data'
initialRootPasswordLength = 16

@automationBootstrap=(event) ->
  event.preventDefault()
  event.stopPropagation()
  action = $(event.target).data('automationScriptAction')
  icon = $(event.target).find('i.fa-plus')
  icon.addClass('hide')
  spinner = $(event.target).find('i.loading-spinner-button')
  spinner.removeClass('hide')
  os_image = $('#server_image_id option:selected').data('vmwareOstype')
  osImageJSON = new Object()
  osImageJSON.vmwareOstype = os_image

  $.ajax
    url: action,
    method: 'POST'
    dataType: 'json'
    data: JSON.stringify(osImageJSON)
    success: ( data, textStatus, jqXHR ) ->
      addScriptToUserAttributes(data.script, os_image)
    complete: () ->
      icon.removeClass('hide')
      spinner.addClass('hide')


@initialRootPassword=(event) ->
  event.stopPropagation()
  event.preventDefault()
  userDataFieldText = $('#server_user_data').val()
  password = "\npassword: '#{randString('a-z,A-Z,0-9,#', initialRootPasswordLength)}'"
  if !userDataFieldText.trim()
    $('#server_user_data').val("#cloud-config#{password}")
  else if userDataFieldText.match("^#cloud-config")
    $('#server_user_data').val("#{$('#server_user_data').val()}#{password}")
  else
    button = $(event.target)
    button.popover(
      title: 'Error'
      content: "This doesn't semm to be a valid cloud config. Cloud config files starts with #cloud-config"
    )
    button.popover('show')
    button.on 'blur', ->
      button.popover('destroy')

@addScriptToUserAttributes = (script, os_image) ->
  osTypeWindows = os_image.search("windows")
  userDataFieldText = $('#server_user_data').val()
  button = $('a[data-toggle="automationBootstrap"]')

  if !userDataFieldText.trim()
    # empty
    $('#server_user_data').val(script)
  else
    # not empty
    if osTypeWindows >= 0
      # windows
      button.popover(
        title: 'Error'
        content: "Bootstrapping the automation agent on windows can’t be combined with other user data."
      )
      button.popover('show')
      button.on 'blur', ->
        button.popover('destroy')
    else
      # linux
      if userDataFieldText.match("^#cloud-config")
        $('#server_user_data').val("#{$('#server_user_data').val()}\n\n#{script}")
      else
        button.popover(
          title: 'Error'
          content: "This doesn't semm to be a valid cloud config. Cloud config files starts with #cloud-config"
        )
        button.popover('show')
        button.on 'blur', ->
          button.popover('destroy')


@randString = (set, size) ->
  dataSet = set.split(',')
  dataSize = size
  possible = ''
  if $.inArray('a-z', dataSet) >= 0
    possible += 'abcdefghijklmnopqrstuvwxyz'
  if $.inArray('A-Z', dataSet) >= 0
    possible += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  if $.inArray('0-9', dataSet) >= 0
    possible += '0123456789'
  if $.inArray('#', dataSet) >= 0
    possible += '![]{}()%&*$#^<>~@|'
  text = ''
  i = 0
  while i < dataSize
    text += possible.charAt(Math.floor(Math.random() * possible.length))
    i++
  text

$ ->
  $(document).on 'click','a[data-toggle="initialRootPassword"]', initialRootPassword
  $(document).on 'click','a[data-toggle="automationBootstrap"]', automationBootstrap