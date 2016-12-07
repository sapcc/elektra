userDataFieldId = '#server_user_data'

@initialRootPassword=(event) ->
  userDataFieldText = $('#server_user_data').val()

  password = "\npassword: '#{randString('a-z,A-Z,0-9,#', 8)}'"
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