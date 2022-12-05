/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const sanitize = function (value) {
  const lt = /</g
  const gt = />/g
  const ap = /'/g
  const ic = /"/g
  return value
    .toString()
    .replace(lt, "&lt;")
    .replace(gt, "&gt;")
    .replace(ap, "&#39;")
    .replace(ic, "&#34;")
}

$.fn.fixedIpSelector = function (options) {
  if (options == null) {
    options = {}
  }
  return this.each(function () {
    const $networkSelect = $(options.networkSelector)
    const $subnetSelect = $(options.subnetSelector)
    const $portInput = $(options.portSelector)
    const $fixedIpInput = $(this)
    const { subnets } = options
    const { ports } = options

    const $ips_container = $("<div/>").insertAfter($fixedIpInput)

    $fixedIpInput
      .autocomplete({
        source: [],
        appendTo: $ips_container,
        minLength: 0,
        select(event, ui) {
          event.preventDefault()
          return $fixedIpInput.val(ui.item.fixed_ips[0]["ip_address"])
        },
      })
      .data("ui-autocomplete")._renderItem = function (ul, port) {
      for (var ip of Array.from(port.fixed_ips)) {
        var description = port.description || port.name
        description = description ? `(${description})` : ""
        return $("<li>").append(`${ip.ip_address} ${description}`).appendTo(ul)
      }
    }

    const updatePortId = function (ip) {
      ip = (ip || "").trim()
      $portInput.val(null)
      return Array.from(ports).map((port) =>
        (() => {
          const result = []
          for (var ip_data of Array.from(port.fixed_ips)) {
            if (ip_data.ip_address.trim() === ip) {
              result.push($portInput.val(port.id))
            } else {
              result.push(undefined)
            }
          }
          return result
        })()
      )
    }

    $fixedIpInput.focus(() => $fixedIpInput.autocomplete("search", ""))
    $fixedIpInput.click(() => $fixedIpInput.autocomplete("search", ""))
    $fixedIpInput.change(function () {
      return updatePortId($(this).val())
    })
    $fixedIpInput.blur(function () {
      return updatePortId($(this).val())
    })

    const updateAvailablePorts = function (subnetId) {
      const selected = $fixedIpInput.val()
      $fixedIpInput.val("")
      $portInput.val("")
      const source = []
      if (subnetId) {
        for (var port of Array.from(ports)) {
          for (var ip of Array.from(port.fixed_ips)) {
            if (ip.subnet_id === subnetId) {
              if (selected === ip.ip_address) {
                $fixedIpInput.val(selected)
              }
              //$portInput.val(port.id)
              var description = port.description || port.name
              description = description ? `(${description})` : ""
              source.push(port)
            }
          }
        }
      }

      return $fixedIpInput.autocomplete("option", "source", source)
    }

    const updateAvailableSubnets = function (networkId) {
      const selected = $subnetSelect.val()
      $subnetSelect.find("option").remove() // remove all options first
      if (!networkId) {
        // indicate to the user that no network is selected
        $subnetSelect.append(
          $("<option value=''>Please choose a network first</option>")
        )
        updateAvailablePorts("")
        return
      }

      const filtered_subnets = subnets.filter(
        (sub) => sub.network_id === networkId
      ) // filter for subnets for the selected network
      $subnetSelect.append(
        $("<option value=''>Choose a subnet (optional)</option>")
      )

      if (filtered_subnets.length > 1) {
        for (var subnet of Array.from(filtered_subnets)) {
          $subnetSelect.append(
            $(
              `<option value='${subnet.id}' ${
                subnet.id === selected ? "selected" : undefined
              }>${sanitize(subnet.name)} (${subnet.cidr})</option>`
            )
          )
        }
        return updateAvailablePorts($subnetSelect.val())
      } else {
        // if network has only one subnet display it to the user but don't actually select it to prevent the special handling with port creation
        const first_subnet = filtered_subnets[0]
        $subnetSelect.append(
          $(
            `<option value='${first_subnet.id}'>${sanitize(
              first_subnet.name
            )} (${first_subnet.cidr})</option>`
          )
        )
        return updateAvailablePorts(first_subnet.id)
      }
    }

    $networkSelect.change(function () {
      return updateAvailableSubnets($(this).val())
    })
    $subnetSelect.change(function () {
      return updateAvailablePorts($(this).val())
    })

    updateAvailableSubnets($networkSelect.val())
    return updateAvailablePorts($subnetSelect.val())
  })
}
