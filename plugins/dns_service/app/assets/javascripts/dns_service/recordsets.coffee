$(document).on 'modal:contentUpdated', () ->
  $( "select[data-dynamic-label]" ).change () ->
    value = $(this).val()
    labelValues = $(this).data(value)
    $target = $($(this).data('dynamicLabel'))
    $label = $('label[for="'+$target.attr('id')+'"]')

    newLabel = if $label.find('abbr').length>0
      '<abbr title="required">*</abbr>'+labelValues.label
    else
      labelValues.label

    $label.html(newLabel)

    # replace input with textarea
    if $target.prop("tagName")=='INPUT' && labelValues.type=='text'
      $textarea = $('<textarea></textarea>')
      $textarea.prop('name', $target.prop('name'))
      $textarea.prop('id', $target.prop('id'))
      $textarea.prop('class', $target.prop('class'))
      $target.replaceWith($textarea)
    # replace textarea with input
    else if $target.prop("tagName")=='TEXTAREA' && labelValues.type!='text'
      $input = $('<input type="text"></input>')
      $input.prop('name', $target.prop('name'))
      $input.prop('id', $target.prop('id'))
      $input.prop('class', $target.prop('class'))
      $target.replaceWith($input)


  # recordset name input event handlers to allow users to create records for just the zone name
  $('#recordset-name-input').focus () ->
    $(this).parent().addClass('addon-active')

  $('#recordset-name-input').blur () ->
    toggleZoneNameDisplay($(this))

  $('#recordset-name-input').keyup (e) ->
    keyCode = e.keyCode || e.which;

    # ignore the tab key (in case user uses tab to focus the input we want the 'on focus' event handler to do its thing, not this one)
    if (keyCode != 9)
      toggleZoneNameDisplay($(this))



toggleZoneNameDisplay = (target) ->
  value = target.val()
  if value.length > 0
    target.parent().addClass('addon-active')
  else
    target.parent().removeClass('addon-active')
