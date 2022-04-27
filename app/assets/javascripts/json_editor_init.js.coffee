@init_json_editor= () ->
  if $('#jsoneditor').length
    content = ""
    if $('#jsoneditor').data('content-id')
      try
        content = JSON.parse(eval($('#jsoneditor').data('content-id')))
      catch err
        content = eval($('#jsoneditor').data('content-id'))
    else
      content = $('#jsoneditor').data('content')
    options =
      mode: $('#jsoneditor').data('mode'),
      onChange: (event) ->
        eval($('#jsoneditor').data('on-change-update-field')).val(editor.getText())
        return

    # build the editor
    if !($('#jsoneditor').data('mode') == "view" && (jQuery.type(content) == 'undefined' || content == ""))
      editor = new JSONEditor(document.getElementById('jsoneditor'), options, content)

      # add resize button
      $('#jsoneditor .jsoneditor .jsoneditor-menu').append( "<a id='jsoneditor-resize' class='jsoneditor-poweredBy'><i class='fa fa-expand'></i><i class='fa fa-compress hide'></i></a>" )
      resizeButton = $('#jsoneditor-resize')
      resizeButton.on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()
        if resizeButton.find('.fa-expand').hasClass('hide')
          resizeButton.find('.fa-expand').removeClass('hide')
          resizeButton.find('.fa-compress').addClass('hide')
          $('#jsoneditor .jsoneditor').removeClass('fullsize')
          if $.isFunction(editor.resize)
            editor.resize()
        else
          resizeButton.find('.fa-expand').addClass('hide')
          resizeButton.find('.fa-compress').removeClass('hide')
          $('#jsoneditor .jsoneditor').addClass('fullsize')
          if $.isFunction(editor.resize)
            editor.resize()

$ ->
  # add handler to the show modal event
  $(document).on('modal:contentUpdated', init_json_editor)

  # init json editor in case not in a modal
  init_json_editor()