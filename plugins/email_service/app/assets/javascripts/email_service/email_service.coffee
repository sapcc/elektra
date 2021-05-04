configset_name = 'input[id="configset_name"]'

email_template_data = 'text_area[id="email_template_data"]'
email_template_name = 'select[id="email_template_name"]'


change_configset_name= (e) ->
  value = $(e.target).val()
  
  # $('.can-be-hidden').text = value
  # if value == "HIDE"
  #   $('.can-be-hidden').addClass('hide')
$ ->

  # $(document).on 'change', configset_name, change_configset_name
  console.log "Document is loaded you see..."

  $(document).on 'click', configset_name, ->
    $( ".can-be-hidden" ).css("color", "red").text("")
    # $( '.can-be-hidden' ).text("warning text")
    # $('.can-be-hidden').addClass('hide')

  $(document).on 'blur', configset_name, ->
    if /\s/.test($(this).val().trim())
      $( '.can-be-hidden' ).text("can't contain space!!")

  $(document).on 'change', email_template_name, ->
    if $(email_template_name).val() == "Preferences" || "Gift_Template"
      $(email_template_data).text('EMPTY STRING')
