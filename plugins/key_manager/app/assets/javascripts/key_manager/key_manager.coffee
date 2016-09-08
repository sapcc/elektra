secret_type_select = 'select[data-toggle="secretTypeSwitcher"]'
secret_payload_content_info = '.js-secret-payload-content-info'
section_spinner = '.key_manager .loading-spinner-section'
container_type_select = 'select[data-toggle="containerTypeSwitcher"]'
container_secrets = '.js-container-secrets'

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

switch_container_type= (e) ->
  value = $(e.target).val()
  # hide area and add spinner
  $(container_secrets).addClass('hide')
  $(section_spinner).removeClass('hide')
  $.ajax
    url: $(e.target).data('update-url'),
    data: {container_type: value},
    dataType: 'script'
    success: ( data, textStatus, jqXHR ) ->
      $(container_secrets).removeClass('hide')
      $(section_spinner).addClass('hide')

@init_select_multiple= () ->
  $('select[data-toggle="selectMultiple"]').multiselect({
    buttonWidth: '100%',
    numberDisplayed: 1
  })
  $( ".btn-group:has(button.multiselect)" ).css("width", "100%")


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