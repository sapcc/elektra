secret_type_select = 'select[data-toggle="secretTypeSwitcher"]'
secret_payload_content_info = '.js-secret-payload-content-info'

container_type_select = 'select[data-toggle="containerTypeSwitcher"]'
container_all_secrets = '.js-container-secrets'
container_secrets = '.js-container-secrets .js-secrets'
container_secrets_naming = '.js-secrets-naming'

section_spinner = '.key_manager .loading-spinner-section'

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
  $('select[data-toggle="selectMultiple"]').multiselect('destroy')
  init_select_multiple()

secrets_container_disable= (container) ->
  $(container).addClass('hide')
  $(container).find('select').each ->
    $(this).prop('disabled', true)
  $('select[data-toggle="selectMultiple"]').multiselect('destroy')
  init_select_multiple()

#
# secrets Multiselect
#

@init_select_multiple= () ->
  # init secret_table obj
  secretsTable = new SecretsTable('.js-secrets-naming', {})
  # init multiselect
  $('select[data-toggle="selectMultiple"]').multiselect({
    buttonWidth: '100%',
    numberDisplayed: 0,
    onChange: (option, checked, select) ->
      secretsTable.updateRow(option, checked)
  })
  # fix the width of the multiselect
  $( ".btn-group:has(button.multiselect)" ).css("width", "100%")

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