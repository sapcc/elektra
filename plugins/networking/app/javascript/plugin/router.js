/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const subnets = {}
const $loader = $('<span class="spinner"></span>')

const showSubnets = function (subnets) {
  const $select = $(
    "#router_external_gateway_info_external_fixed_ips_subnet_id"
  )
  const selected = $select.data("selected")
  $select.empty()

  $select.append('<option value=""></option>')
  for (var subnet of Array.from(subnets)) {
    var available_ips = subnet.total_ips - subnet.used_ips
    var isSelectedInfo =
      $.inArray(subnet.subnet_id, selected) > -1 ? "selected" : ""
    var isDisabledInfo = available_ips <= 0 ? "disabled" : ""

    $select.append(
      `<option ${isSelectedInfo} ${isDisabledInfo} value="${subnet.subnet_id}">${subnet.subnet_name} (${subnet.cidr}, available IPs: ${available_ips})</option>`
    )
  }

  if ($select.val().trim().length === 0) {
    $('form[data-router-form=true] button[type="submit"]').prop(
      "disabled",
      true
    )
  } else {
    $('form[data-router-form=true] button[type="submit"]').prop(
      "disabled",
      false
    )
  }

  return $("fieldset#subnets .form-group").show()
}

const loadSubnets = function (networkId) {
  if (!networkId || networkId.trim().length === 0) {
    $("fieldset#subnets .form-group").hide()
    $('form[data-router-form=true] button[type="submit"]').prop(
      "disabled",
      false
    )
    return
  }

  if (subnets[networkId]) {
    return showSubnets(subnets[networkId])
  } else {
    $('form[data-router-form=true] button[type="submit"]').prop(
      "disabled",
      true
    )
    $("fieldset#subnets .form-group").hide()
    $("fieldset#subnets").append($loader)
    return $.ajax({
      //url: "networks/#{networkId}/ip_availability"
      url: `${window.location.protocol}//${window.location.host}/${scopedDomainFid}/${scopedProjectFid}/networking/networks/${networkId}/ip_availability`,
      success(data, textStatus, jqXHR) {
        subnets[networkId] = data
        $loader.remove()
        return showSubnets(subnets[networkId])
      },
    })
  }
}

const init = function () {
  if (
    $("#router_external_gateway_info_external_fixed_ips_subnet_id").length ===
      0 ||
    (
      $("#router_external_gateway_info_external_fixed_ips_subnet_id")[0]
        .value || ""
    ).trim().length === 0
  ) {
    $("fieldset#subnets .form-group").hide()
    $('form[data-router-form=true] button[type="submit"]').prop(
      "disabled",
      true
    )
  }

  $("#router_external_gateway_info_network_id").change(function () {
    return loadSubnets(this.value)
  })

  if ($("#router_external_gateway_info_network_id").val()) {
    loadSubnets($("#router_external_gateway_info_network_id").val())
  }

  return $("#router_external_gateway_info_external_fixed_ips_subnet_id").change(
    function () {
      if (this.value.trim().length === 0) {
        return $('form[data-router-form=true] button[type="submit"]').prop(
          "disabled",
          true
        )
      } else {
        return $('form[data-router-form=true] button[type="submit"]').prop(
          "disabled",
          false
        )
      }
    }
  )
}

$(document).on("modal:contentUpdated", (e) => init())
