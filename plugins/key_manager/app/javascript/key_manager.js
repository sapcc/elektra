/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const secret_type_select = 'select[data-toggle="secretTypeSwitcher"]'
const payload_content_type_select =
  'select[data-toggle="secretPayloadTypeSwitcher"]'
const secret_payload_content_info = ".js-secret-payload-content-info"

const container_type_select = 'select[data-toggle="containerTypeSwitcher"]'
const container_all_secrets = ".js-container-secrets"
const container_secrets = ".js-container-secrets .js-secrets"
const container_secrets_naming = ".js-secrets-naming"

const section_spinner = ".key_manager .loading-spinner-section"

const orig_select = 'select[data-toggle="selectMultiple"]'
const multiselect = ".js-generic .multiselect-native-select"
let secretsTable = null

const switch_secret_content_type = function (e) {
  const value = $(e.target).val()
  // hide area and add spinner
  $(secret_payload_content_info).addClass("hide")
  // return if value is empty
  if (!value || value.trim().length === 0) {
    return
  }

  $(section_spinner).removeClass("hide")
  return $.ajax({
    url: $(e.target).data("update-url"),
    data: { secret_type: value },
    dataType: "script",
    success(data, textStatus, jqXHR) {
      $(secret_payload_content_info).removeClass("hide")
      return $(section_spinner).addClass("hide")
    },
  })
}

const switch_secret_payload_content_type = function (e) {
  const relation = $(payload_content_type_select).data("encoding-relation")
  const val = $(e.target).val()
  if (relation[val] === null) {
    $(".js-secret-encoding").addClass("hide")
    return $("#secret_payload_content_encoding").prop("disabled", true)
  } else {
    $("#secret_payload_content_encoding").prop("disabled", false)
    return $(".js-secret-encoding").removeClass("hide")
  }
}

const init_date_time_picker = () =>
  $(".form_datetime").datetimepicker({
    autoclose: true,
    todayBtn: true,
    pickerPosition: "bottom-left",
    container: ".secret_expiration .input-wrapper",
  })

//
// Containers
//

const switch_container_type = function (e) {
  const value = $(e.target).val()

  // hide area and add spinner
  $(container_all_secrets).addClass("hide")
  $(section_spinner).removeClass("hide")

  $(container_secrets).each(function () {
    if ($(this).hasClass(`js-${value}`)) {
      return secrets_container_enable($(this))
    } else {
      return secrets_container_disable($(this))
    }
  })

  return setTimeout(function () {
    $(container_all_secrets).removeClass("hide")
    return $(section_spinner).addClass("hide")
  }, 500)
}

var secrets_container_enable = function (container) {
  $(container).removeClass("hide")
  return $(container)
    .find("select")
    .each(function () {
      return $(this).prop("disabled", false)
    })
}

var secrets_container_disable = function (container) {
  $(container).addClass("hide")
  return $(container)
    .find("select")
    .each(function () {
      return $(this).prop("disabled", true)
    })
}

//
// secrets Multiselect
//

const init_select_multiple = function () {
  // init secret_table obj
  secretsTable = new SecretsTable(".js-secrets-naming", {
    onRemoveRow(row_id) {
      return update_multiselect_option(row_id, false)
    },
  })

  // init multiselect
  $(orig_select).multiselect({
    buttonWidth: "100%",
    numberDisplayed: 0,
    buttonText(options, select) {
      return "Select secrets"
    },
    onInitialized(select, container) {
      // get selected options
      const selected_options = $(orig_select).data("selected")
      // add selected options to the table
      return add_secret(selected_options)
    },
  })
  // fix the width of the multiselect
  $(".btn-group:has(button.multiselect)").css("width", "100%")
}

var add_secret = (selected_options) =>
  // check new selected options
  $(multiselect)
    .find("input")
    .each(function () {
      let value
      if ($(this).is(":checked") && !$(this).prop("disabled")) {
        value = $(this).val()
        const option = $(orig_select).find(`option[value='${value}']`)

        // update table row
        if (
          selected_options !== undefined &&
          !$.isEmptyObject(selected_options)
        ) {
          const name =
            selected_options[value] !== undefined
              ? selected_options[value]["name"]
              : undefined
          secretsTable.updateRow(option, true, name)
        } else {
          secretsTable.updateRow(option, true)
        }
      }

      // hide selected options
      return update_multiselect_option(value, true)
    })

var update_multiselect_option = function (option_val, disabled) {
  // select option
  const input = $(multiselect + ' input[value="' + option_val + '"]')

  // deselect option and remove active class
  input.prop("checked", false)
  input.parents("li").removeClass("active")

  // enable or disable options
  if (disabled) {
    input.prop("disabled", true)
    return input.parents("li").addClass("disabled hidden")
  } else {
    input.prop("disabled", false)
    input.parents("li").removeClass("disabled")
    return input.parents("li").removeClass("hidden")
  }
}

//
// Inits
//

$(function () {
  // add handler to the secret type select
  $(document).on("change", secret_type_select, switch_secret_content_type)

  // add handler to the secret type select
  $(document).on(
    "change",
    payload_content_type_select,
    switch_secret_payload_content_type
  )

  // init date time picker
  $(document).on("modal:contentUpdated", init_date_time_picker)
  init_date_time_picker()

  // add handler to the container type select
  $(document).on("change", container_type_select, switch_container_type)

  // init select multiple
  $(document).on("modal:contentUpdated", init_select_multiple)
  init_select_multiple()

  // init add secrets button
  return $(document).on("click", ".js-add-generic-secrets", () => add_secret())
})
