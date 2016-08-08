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
        