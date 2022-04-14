class SecretsTable

  table = null
  tableOpts = null
  container = null

  constructor: (cont, opts={}) ->
    tableOpts = opts
    container = cont

    # create table id
    table_id = opts['id'] || 'secrets_table_edit_name'

    # check
    if $(container).length
      # if table exists remove table
      if $('#'+table_id).length > 0
        $('#'+table_id).remove()

      # create a new table
      table =  $( "<table class='table' id='" + table_id + "'>" +
                    "<thead>" +
                      "<tr><th>Secret</th><th>Container secret label</th><th class='snug'></th></tr>" +
                    "</thead>" +
                    "<tbody>" +
                      emptyRow() +
                    "</tbody>" +
                  "</table>")
      $(container).append(table)

  emptyRow= () ->
    return "<tr id='emptyRow'><td colspan='3'>No secrets selected</td></tr>"

  inputName= (name, id, value, hidden) ->
    computed_name = "container[secrets][generic][" + id + "][" + name + "]"
    computed_id = "container_secrets_generic_" + id + "_" + name
    if hidden
      return "<input type='hidden' class='form-control' placeholder='Enter " + name + "' type='text' name='" + computed_name + "' id='" + computed_id + "' value='" + value + "' >"
    else
      return "<input class='form-control' placeholder='Enter " + name + "' type='text' name='" + computed_name + "' id='" + computed_id + "' value='" + value + "' >"

  updateRow: (option, checked, text) ->
    secret_name = option.data("name")
    secret_value = secret_name
    if text != undefined
      secret_value = text
    secret_ref = option.data("secret-ref")
    secret_uuid = option.data("uuid")

    if checked == true
      # add new row
      table.find('tbody').append('<tr id="' + secret_uuid + '">' +
          '<td>'  + secret_name +  '</td>'+
          '<td>'+ inputName("name", secret_uuid, secret_value, false) + inputName("secret_ref", secret_uuid, secret_ref, true) + '</td>'+
          '<td>'+
          '<a class="btn btn-default btn-sm" data-toggle="genericSecretRemove" href="#"><i class="fa fa-trash fa-fw"></i></a>' +
          '</td>' +
          '</tr>')

      # add event
      table.find('tr#' + secret_uuid + " a[data-toggle='genericSecretRemove']").click ->
        # remove row
        table.find('tr#' + secret_uuid).remove()
        # callback
        if tableOpts.onRemoveRow
          tableOpts.onRemoveRow(secret_uuid)

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

window.SecretsTable = SecretsTable