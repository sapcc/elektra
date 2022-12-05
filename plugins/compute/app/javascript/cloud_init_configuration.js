/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const CloudInit = {}
CloudInit.automationBootstrap = function (event) {
  event.preventDefault()
  event.stopPropagation()
  const button = $(event.target)
  const action_path = $(event.target).data("automationScriptAction")

  let os_image_option = $("#server_vmware_image_id option:selected")
  if ($("#server_baremetal_image_id").val() !== "") {
    os_image_option = $("#server_baremetal_image_id option:selected")
  }

  return CloudInit.checkOsType(button, os_image_option, action_path)
}

CloudInit.fetchLinuxScritp = function (event) {
  event.preventDefault()
  event.stopPropagation()
  const button = $(event.target)
  const action_path = button.data("automationScriptAction")
  $('a[data-toggle="windowsAutomationScript"]').addClass("disabled")
  CloudInit.startSpinner(button)
  return CloudInit.fetchAutomationScript(button, "linux", action_path)
}

CloudInit.fetchWindowsScritp = function (event) {
  event.preventDefault()
  event.stopPropagation()
  const button = $(event.target)
  const action_path = button.data("automationScriptAction")
  $('a[data-toggle="linuxAutomationScript"]').addClass("disabled")
  CloudInit.startSpinner(button)
  return CloudInit.fetchAutomationScript(button, "windows", action_path)
}

CloudInit.startSpinner = function (button) {
  const icon = button.find("i.fa-plus")
  const spinner = button.find("i.loading-spinner-button")
  icon.addClass("hide")
  spinner.removeClass("hide")
  return button.addClass("disabled")
}

CloudInit.stopSpinner = function (button) {
  const icon = button.find("i.fa-plus")
  const spinner = button.find("i.loading-spinner-button")
  icon.removeClass("hide")
  spinner.addClass("hide")
  return button.removeClass("disabled")
}

CloudInit.addEventListenerOnSelect = function (button) {
  $("#server_vmware_image_id").unbind("change")
  $("#server_vmware_image_id").bind("change", () =>
    CloudInit.removeOsTypeButtons()
  )
  $("#server_baremetal_image_id").unbind("change")
  return $("#server_baremetal_image_id").bind("change", () =>
    CloudInit.removeOsTypeButtons()
  )
}

CloudInit.checkOsType = function (button, os_image_option, action_path) {
  const os_image = os_image_option.data("vmwareOstype")

  // check empty image
  if (os_image_option.val() === "") {
    CloudInit.attachPopover(button, "Error", "Please choose an image.")
    return
  }
  // check image
  if (os_image === "" || os_image === null || typeof os_image === "undefined") {
    CloudInit.attachPopover(
      button,
      "Warning",
      "Missing property 'vmware_ostype' on the image provided. Please follow the steps described in the documentation to upload a compatible image. <a href='https://documentation.global.cloud.sap/docs/customer/compute/os-image/customer-image/'>See customer images documentation</a>. Please choose manually."
    )
    CloudInit.addEventListenerOnSelect(button)
    CloudInit.addOsTypeButtons(button, action_path)

    return
  }
  // get script
  $('a[data-toggle="windowsAutomationScript"]').addClass("disabled")
  CloudInit.startSpinner(button)
  return CloudInit.fetchAutomationScript(button, os_image, action_path)
}

CloudInit.addOsTypeButtons = function (button, action_path) {
  CloudInit.removeOsTypeButtons()
  if (button.attr("data-toggle") === "CloudInit.automationBootstrap") {
    return button.before(
      '<span class="osTypeOptionButtons">' +
        '<a href="#" class="btn btn-default btn-xs" data-toggle="linuxAutomationScript" data-automation-script-action="' +
        action_path +
        '">' +
        '<i class="fa fa-plus fa-fw"></i><i class="loading-spinner-button hide"></i>Linux</a>' +
        '<a href="#" class="btn btn-default btn-xs" data-toggle="windowsAutomationScript" data-automation-script-action="' +
        action_path +
        '">' +
        '<i class="fa fa-plus fa-fw"></i><i class="loading-spinner-button hide"></i>Windows</a>' +
        "</span>"
    )
  }
}

CloudInit.removeOsTypeButtons = () => $(".osTypeOptionButtons").remove()

CloudInit.fetchAutomationScript = function (button, os_image, action_path) {
  const osImageJSON = new Object()
  osImageJSON.vmwareOstype = os_image
  return $.ajax({
    url: action_path,
    method: "POST",
    dataType: "json",
    data: JSON.stringify(osImageJSON),
    success(data, textStatus, jqXHR) {
      return CloudInit.addScriptToUserAttributes(data.script, button, os_image)
    },
    error(xhr, bleep, error) {
      return CloudInit.attachPopover(
        button,
        "Error",
        "Something went wrong while processing your request. Please try again later."
      )
    },
    complete() {
      return CloudInit.stopSpinner(button)
    },
  })
}

CloudInit.addScriptToUserAttributes = function (script, button, os_image) {
  const osTypeWindows = os_image.search("windows")
  const userDataFieldText = $("#server_user_data").val()

  if (!userDataFieldText.trim()) {
    // empty
    $("#server_user_data").val(script)
    return CloudInit.removeOsTypeButtons()
  } else {
    // not empty
    if (osTypeWindows >= 0) {
      // windows
      return CloudInit.attachPopover(
        button,
        "Error",
        "Bootstrapping the automation agent on windows can’t be combined with other user data."
      )
    } else {
      // linux
      if (userDataFieldText.match("^#cloud-config")) {
        $("#server_user_data").val(
          `${$("#server_user_data").val()}\n\n${script}`
        )
        return CloudInit.removeOsTypeButtons()
      } else {
        return CloudInit.attachPopover(
          button,
          "Error",
          "This doesn't semm to be a valid cloud config. Cloud config files starts with #cloud-config"
        )
      }
    }
  }
}

CloudInit.attachPopover = function (element, title, body) {
  element.find(".popover").remove()
  element.popover({
    title,
    content: body,
    html: true,
    placement: "top",
  })
  element.popover("show")
  return element.off("blur").on("blur", () => element.popover("destroy"))
}

$(function () {
  $(document).on(
    "click",
    'a[data-toggle="automationBootstrap"]',
    CloudInit.automationBootstrap
  )
  $(document).on(
    "click",
    'a[data-toggle="linuxAutomationScript"]',
    CloudInit.fetchLinuxScritp
  )
  return $(document).on(
    "click",
    'a[data-toggle="windowsAutomationScript"]',
    CloudInit.fetchWindowsScritp
  )
})
