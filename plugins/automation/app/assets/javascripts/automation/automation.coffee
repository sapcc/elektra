@init_tag_editor_inputs= () ->
  $('textarea[data-toggle="tagEditor"]').tagEditor({ placeholder: 'Enter key value tags' })


$ ->
  # add handler to the show modal event
  $(document).on('modal:shown_success', init_tag_editor_inputs)

  # init tag editors
  init_tag_editor_inputs()
