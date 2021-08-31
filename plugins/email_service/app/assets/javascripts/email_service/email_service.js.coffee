# email_source = 'input[id="email_source"]'
# email_to_addr = 'text_area[id="email_to_addr"]'
# email_cc_addr = 'text_area[id="email_cc_addr"]'
# email_bcc_addr = 'text_area[id="email_bcc_addr"]'


# email_template_name = 'select[id="email_template_name"]'
# email_template_data = 'text_area[id="email_template_data"]'

# configset_name = 'input[id="configset_name"]'

# change_configset_name = (e) ->
#   value = $(e.target).val()



# get_value = (e) ->
#   console.log "Inside get value"
#   value = $(e.target).val()
#   console.log value

# exec_plain_email = () ->
#   console.log "exec_plain_email touched"
#   $(document).on 'change', email_to_addr, get_value
#   $(document).on 'change', email_cc_addr, get_value
#   $(document).on 'change', email_source, get_value

# $ ->
#   # email form
#   console.log "Document is loaded; email_service.js.coffee"
#   $(document).on('modal:contentUpdated', exec_plain_email)
#   console.log "Document is loaded you see...Coffee " # works

# $(document).on 'change', configset_name, change_configset_name

#   $(document).on 'click', configset_name, ->
#     $( '#configsetNameHelp' ).toggle()
#     $( "#configsetNameHelp" ).css("color", "blue")
#     console.log "blue color text"
#     # $( '#configsetNameHelp' ).hide()
#     # $( '#configsetNameHelp' ).addClass('hide')
#     # $( '#configsetNameHelp' ).addClass('hidden')

#   $(document).on 'blur', configset_name, ->
#     $( "#configsetNameHelp" ).css("color", "yellow")
#     $( '#configsetNameHelp' ).hide()
#     console.log "yellow color text"

#   $(document).on 'change', configset_name, get_value

#   exec_plain_email()

# #   $(document).on 'blur', configset_name, ->
# #     # if /\s/.test($(this).val().trim()) # /$|\s+/ or /(.|\s)*\S(.|\s)*/ empty or contains space #->  /\s/ - in between space
# #     if /^[a-z0-9_-]{3,15}$/.test($(this).val().trim())
# #       $( '#configsetNameHelp' ).text("Configset name can't be empty or contain space")
# #       $( '#configsetNameHelp' ).removeClass('hide')
# #     # if /^[a-zA-Z0-9_]+/.test($(this).val().trim()) # one or more special character
# #     #   $( '.can-be-hidden' ).text("Configset name can't have special characters, only alphanumeric and underscores _ are allowed")


#   $(document).on 'change', email_template_name, ->
#     console.log "EMail Template name: #{email_template_name.val}"
#     if $(email_template_name).val() == "Preferences" || "Gift_Template"
#       $(email_template_data).text('EMPTY STRING')

