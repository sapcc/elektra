secret_type_select = 'select[data-toggle="secretTypeSwitcher"]'

switch_content_type= (e) ->
  value = $(e.target).val()
  $.ajax
    url: $(e.target).data('update-url'),
    data: {secret_type: value},
    dataType: 'script'

init_date_time_picker= () ->
  $('.form_datetime').datetimepicker
    autoclose: true
    todayBtn: true
    pickerPosition: "bottom-left"
    format: "yyyy-mm-ddThh:mm:ssZ"
    container: '.secret_expiration .input-wrapper'

$ ->
  # add handler to the secret type select
  $(document).on 'change',secret_type_select, switch_content_type

  # init date time picker
  $(document).on('modal:contentUpdated', init_date_time_picker)
  init_date_time_picker()