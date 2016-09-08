secret_type_select = 'select[data-toggle="secretTypeSwitcher"]'
payload_content_info = '.js-secret-payload-content-info'
section_spinner = '.key_manager .loading-spinner-section'

switch_content_type= (e) ->
  value = $(e.target).val()
  # hide area and add spinner
  $(payload_content_info).addClass('hide')
  $(section_spinner).removeClass('hide')
  $.ajax
    url: $(e.target).data('update-url'),
    data: {secret_type: value},
    dataType: 'script'
    success: ( data, textStatus, jqXHR ) ->
      $(payload_content_info).removeClass('hide')
      $(section_spinner).addClass('hide')


init_date_time_picker= () ->
  $('.form_datetime').datetimepicker
    autoclose: true
    todayBtn: true
    pickerPosition: "bottom-left"
    container: '.secret_expiration .input-wrapper'

$ ->
  # add handler to the secret type select
  $(document).on 'change',secret_type_select, switch_content_type

  # init date time picker
  $(document).on('modal:contentUpdated', init_date_time_picker)
  init_date_time_picker()