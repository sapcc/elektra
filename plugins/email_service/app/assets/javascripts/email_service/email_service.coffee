configset_name = 'input[id="configset_name"]'

email_template_name = 'select[id="email_template_name"]'
email_template_data = 'text_area[id="email_template_data"]'

change_configset_name= (e) ->
  value = $(e.target).val()
  
$ ->
  # $(document).on 'change', configset_name, change_configset_name
  # console.log "Document is loaded you see..." # works

  # $(document).on 'click', configset_name, ->
  #   $( "#configsetNameHelp" ).css("color", "red").text("") # works

  $(document).on 'click', configset_name, ->
    $( '#configsetNameHelp' ).addClass('hide')

  $(document).on 'blur', configset_name, ->
    # if /\s/.test($(this).val().trim()) # /$|\s+/ or /(.|\s)*\S(.|\s)*/ empty or contains space #->  /\s/ - in between space
    if /^[a-z0-9_-]{3,15}$/.test($(this).val().trim())
      $( '#configsetNameHelp' ).text("Configset name can't be empty or contain space")
      $( '#configsetNameHelp' ).removeClass('hide')
    # if /^[a-zA-Z0-9_]+/.test($(this).val().trim()) # one or more special character
    #   $( '.can-be-hidden' ).text("Configset name can't have special characters, only alphanumeric and underscores _ are allowed")


  $(document).on 'change', email_template_name, ->
    console.log "EMail Template name: #{email_template_name.val}"
    if $(email_template_name).val() == "Preferences" || "Gift_Template"
      $(email_template_data).text('EMPTY STRING')
