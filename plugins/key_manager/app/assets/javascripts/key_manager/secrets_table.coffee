class @SecretsTable

  table = null
  options = null

  constructor: (container, opts={}) ->
    options = opts
    table =  $("<table class='table'>" +
                  "<thead>" +
                  "<tr><th>Name</th><th>Reference</th></tr>" +
                  "</thead>" +
                  "<tbody>" +
                  emptyRow() +
                  "</table>")

    if $(container).length
      $(container).append(table)

  emptyRow= () ->
    return "<tr id='emptyRow'><td colspan='2'>No secrets selected</td></tr>"

  inputName= (placeholder, name, readonly) ->
    input = "<input class='form-control' placeholder='Enter name' type='text' name='secrets_names[" + name + "]' id='" + name + "' value='" + placeholder + "'"
    if readonly
      input += "readonly='" + readonly + "'" + " >"
    else
      input += " >"
    return input

  updateRow: (option, checked) ->
    obj = jQuery.parseJSON( option.val() )

    if checked == true
      # add new row
      table.find('tbody').append('<tr id="' + obj.uuid + '"><td>'+ inputName(obj.name, obj.uuid, false) + '</td><td>' + obj.secret_ref + '</td></tr>')
      # check if empty row should be removed
      if table.find('tbody tr').size() >= 2
        table.find('#emptyRow').remove()
    else
      # remove row
      table.find('#'+obj.uuid).remove()
      if table.find('tbody tr').size() == 0
        table.find('tbody').append(emptyRow())


