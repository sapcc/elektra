/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
var SecretsTable = (function () {
  let table = undefined
  let tableOpts = undefined
  let container = undefined
  let emptyRow = undefined
  let inputName = undefined
  SecretsTable = class SecretsTable {
    static initClass() {
      table = null
      tableOpts = null
      container = null

      emptyRow = () =>
        "<tr id='emptyRow'><td colspan='3'>No secrets selected</td></tr>"

      inputName = function (name, id, value, hidden) {
        const computed_name = `container[secrets][generic][${id}][${name}]`
        const computed_id = `container_secrets_generic_${id}_${name}`
        if (hidden) {
          return `<input type='hidden' class='form-control' placeholder='Enter ${name}' type='text' name='${computed_name}' id='${computed_id}' value='${value}' >`
        } else {
          return `<input class='form-control' placeholder='Enter ${name}' type='text' name='${computed_name}' id='${computed_id}' value='${value}' >`
        }
      }
    }

    constructor(cont, opts) {
      if (opts == null) {
        opts = {}
      }
      tableOpts = opts
      container = cont

      // create table id
      const table_id = opts["id"] || "secrets_table_edit_name"

      // check
      if ($(container).length) {
        // if table exists remove table
        if ($(`#${table_id}`).length > 0) {
          $(`#${table_id}`).remove()
        }

        // create a new table
        table = $(
          `<table class='table' id='${table_id}'>` +
            "<thead>" +
            "<tr><th>Secret</th><th>Container secret label</th><th class='snug'></th></tr>" +
            "</thead>" +
            "<tbody>" +
            emptyRow() +
            "</tbody>" +
            "</table>"
        )
        $(container).append(table)
      }
    }

    updateRow(option, checked, text) {
      const secret_name = option.data("name")
      let secret_value = secret_name
      if (text !== undefined) {
        secret_value = text
      }
      const secret_ref = option.data("secret-ref")
      const secret_uuid = option.data("uuid")

      if (checked === true) {
        // add new row
        table
          .find("tbody")
          .append(
            `<tr id="${secret_uuid}">` +
              "<td>" +
              secret_name +
              "</td>" +
              "<td>" +
              inputName("name", secret_uuid, secret_value, false) +
              inputName("secret_ref", secret_uuid, secret_ref, true) +
              "</td>" +
              "<td>" +
              '<a class="btn btn-default btn-sm" data-toggle="genericSecretRemove" href="#"><i class="fa fa-trash fa-fw"></i></a>' +
              "</td>" +
              "</tr>"
          )

        // add event
        table
          .find(`tr#${secret_uuid} a[data-toggle='genericSecretRemove']`)
          .click(function () {
            // remove row
            table.find(`tr#${secret_uuid}`).remove()
            // callback
            if (tableOpts.onRemoveRow) {
              return tableOpts.onRemoveRow(secret_uuid)
            }
          })

        // check if empty row should be removed
        if (table.find("tbody tr").size() >= 2) {
          table.find("#emptyRow").remove()
          return $(container).removeClass("hide")
        }
      } else {
        // remove row
        table.find(`tr#${secret_uuid}`).remove()
        if (table.find("tbody tr").size() === 0) {
          table.find("tbody").append(emptyRow())
          return $(container).addClass("hide")
        }
      }
    }
  }
  SecretsTable.initClass()
  return SecretsTable
})()

window.SecretsTable = SecretsTable
