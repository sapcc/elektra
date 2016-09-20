secret_type_select = 'select[data-toggle="secretTypeSwitcher"]'
secret_payload_content_info = '.js-secret-payload-content-info'

container_type_select = 'select[data-toggle="containerTypeSwitcher"]'
container_all_secrets = '.js-container-secrets'
container_secrets = '.js-container-secrets .js-secrets'
container_secrets_naming = '.js-secrets-naming'

section_spinner = '.key_manager .loading-spinner-section'

orig_select = 'select[data-toggle="selectMultiple"]'
multiselect = '.js-generic .multiselect-native-select'
secretsTable = null

switch_content_type= (e) ->
  value = $(e.target).val()
  # hide area and add spinner
  $(secret_payload_content_info).addClass('hide')
  $(section_spinner).removeClass('hide')
  $.ajax
    url: $(e.target).data('update-url'),
    data: {secret_type: value},
    dataType: 'script'
    success: ( data, textStatus, jqXHR ) ->
      $(secret_payload_content_info).removeClass('hide')
      $(section_spinner).addClass('hide')

init_date_time_picker= () ->
  $('.form_datetime').datetimepicker
    autoclose: true
    todayBtn: true
    pickerPosition: "bottom-left"
    container: '.secret_expiration .input-wrapper'

#
# Containers
#

switch_container_type= (e) ->
  value = $(e.target).val()

  # hide area and add spinner
  $(container_all_secrets).addClass('hide')
  $(section_spinner).removeClass('hide')

  $(container_secrets).each ->
    if $(this).hasClass("js-"+value)
      secrets_container_enable($(this))
    else
      secrets_container_disable($(this))

  setTimeout(->
    $(container_all_secrets).removeClass('hide')
    $(section_spinner).addClass('hide')
  , 500);

secrets_container_enable= (container) ->
  $(container).removeClass('hide')
  $(container).find('select').each ->
   $(this).prop('disabled', false)
  $(orig_select).multiselect('destroy')
  init_select_multiple()

secrets_container_disable= (container) ->
  $(container).addClass('hide')
  $(container).find('select').each ->
    $(this).prop('disabled', true)
  $(orig_select).multiselect('destroy')
  init_select_multiple()

#
# secrets Multiselect
#

@init_select_multiple= () ->
  # init secret_table obj
  secretsTable = new SecretsTable('.js-secrets-naming', {
    onRemoveRow: (row_id) ->
      update_multiselect_option(row_id, false)
  })

  # init multiselect
  $(orig_select).multiselect({
    buttonWidth: '100%',
    numberDisplayed: 0,
    buttonText: (options, select) ->
      return "Select secrets"
    onInitialized: (select, container) ->
      add_secret()

  })
  # fix the width of the multiselect
  $( ".btn-group:has(button.multiselect)" ).css("width", "100%")
  return

update_multiselect_option= (option_val, disabled) ->
  input = $(multiselect + ' input[value="' + option_val + '"]')
  input.prop('checked', false)
  input.parents('li').removeClass 'active'
  if disabled
    input.prop 'disabled', true
    input.parents('li').addClass 'disabled hidden'
  else
    input.prop 'disabled', false
    input.parents('li').removeClass 'disabled'
    input.parents('li').removeClass 'hidden'

add_secret= (names) ->
 $(multiselect).find('input').each ->
   if $(this).is(":checked") && !$(this).prop('disabled')
     value = $(this).val()
     option = $(orig_select).find("option[value='"+ value + "']")
     # update table

     console.log(names)

     if names != undefined
       secretsTable.updateRow(option, true, "test")
     else
       secretsTable.updateRow(option, true)
     # hide selected options
     update_multiselect_option(value, true)


#
# Inits
#


$ ->
  # add handler to the secret type select
  $(document).on 'change',secret_type_select, switch_content_type

  # init date time picker
  $(document).on('modal:contentUpdated', init_date_time_picker)
  init_date_time_picker()

  # add handler to the container type select
  $(document).on 'change', container_type_select, switch_container_type

  # init select multiple
  $(document).on('modal:contentUpdated', init_select_multiple)
  init_select_multiple()

  # init add secrets button
  $(document).on 'click', ".js-add-generic-secrets", ->
    add_secret()
