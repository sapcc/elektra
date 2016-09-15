class @SecretsTable

  table = null
  options = null
  container = null

  constructor: (cont, opts={}) ->
    options = opts
    container = cont
    table_id = opts['id'] || 'secrets_table_edit_name'
    table =  $("<table class='table' id='" + table_id + "'>" +
                  "<thead>" +
                  "<tr><th>Secret</th><th>Container secret label</th></tr>" +
                  "</thead>" +
                  "<tbody>" +
                  emptyRow() +
                  "</table>")

    if $(container).length && $('#'+table_id).length == 0
      $(container).append(table)

  emptyRow= () ->
    return "<tr id='emptyRow'><td colspan='2'>No secrets selected</td></tr>"

  inputName= (name, id, value, hidden) ->
    computed_name = "generic_secret[" + id + "][" + name + "]"
    computed_id = "generic_secret_" + id + "_" + name
    if hidden
      return "<input type='hidden' class='form-control' placeholder='Enter " + name + "' type='text' name='" + computed_name + "' id='" + computed_id + "' value='" + value + "' >"
    else
      return "<input class='form-control' placeholder='Enter " + name + "' type='text' name='" + computed_name + "' id='" + computed_id + "' value='" + value + "' >"

  updateRow: (option, checked) ->
    secret_name = option.data("name")
    secret_ref = option.data("secret-ref")
    secret_uuid = option.data("uuid")

    if checked == true
      # add new row
      table.find('tbody').append('<tr id="' + secret_uuid + '"><td>'  + secret_name +  '</td><td>'+ inputName("name", secret_uuid, secret_name, false) + inputName("secret_ref", secret_uuid, secret_ref, true) + '</td></tr>')
      # check if empty row should be removed
      if table.find('tbody tr').size() >= 2
        table.find('#emptyRow').remove()
        $(container).removeClass('hide')
    else
      # remove row
      table.find('tr#'+secret_uuid).remove()
      if table.find('tbody tr').size() == 0
        table.find('tbody').append(emptyRow())
        $(container).addClass('hide')


