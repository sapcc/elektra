var init_tag_editor_inputs,
  run_automation_link,
  select_automation_instance,
  switch_automation_type,
  update_submit_button

init_tag_editor_inputs = function () {
  $(
    'textarea[data-toggle="tagEditor"][data-tageditor-name="environment"]'
  ).each(function () {
    return $(this).tagEditor({
      placeholder: $(this).attr("placeholder") || "Enter key value pairs",
      keyValueEntries: true,
      forceLowercase: false,
      maxLength: 255,
      delimiter: "¡",
    })
  })
  $('textarea[data-toggle="tagEditor"][data-tageditor-name="arguments"]').each(
    function () {
      return $(this).tagEditor({
        placeholder: $(this).attr("placeholder") || "Enter tags",
        keyValueEntries: false,
        forceLowercase: false,
        maxLength: 255,
        delimiter: "¡",
      })
    }
  )
  $('textarea[data-toggle="tagEditor"][data-tageditor-name="runlist"]').each(
    function () {
      return $(this).tagEditor({
        placeholder: $(this).attr("placeholder") || "Enter tags",
        keyValueEntries: false,
        forceLowercase: false,
        maxLength: 255,
        delimiter: "¡",
      })
    }
  )
  return $(
    'textarea[data-toggle="tagEditor"][data-tageditor-name="tags"]'
  ).each(function () {
    return $(this).tagEditor({
      placeholder: $(this).attr("placeholder") || "Enter tags",
      keyValueEntries: true,
      forceLowercase: true,
      maxLength: 255,
      delimiter: "¡",
    })
  })
}

switch_automation_type = function (event) {
  var value
  value = event.target.value
  if (value === "chef") {
    $("#chef-automation").removeClass("hide")
    return $("#script-automation").addClass("hide")
  } else if (value === "script") {
    $("#script-automation").removeClass("hide")
    return $("#chef-automation").addClass("hide")
  }
}

select_automation_instance = function (event) {
  var value
  value = event.target.value
  if (value === "external") {
    return $(".js-external-instance").removeClass("hide")
  } else {
    return $(".js-external-instance").addClass("hide")
  }
}

run_automation_link = function (event) {
  var btn_group, node_id, spinner
  node_id = $(event.target).data("node-id")
  spinner = $("i.loading-spinner-section[data-node-id=" + node_id + "]")
  spinner.removeClass("hide")
  btn_group = $(".btn-group[data-node-id=" + node_id + "]")
  btn_group.addClass("hide")
  return $.ajax({
    url: $(event.target).data("link"),
    dataType: "html",
    success: function (data, textStatus, jqXHR) {
      if ($(data).hasClass("flashes")) {
        return $(".flashes").append($(data).contents())
      } else {
        return $(".flashes").append(data)
      }
    },
    error: function (request, status, error) {
      return $(".flashes").append(request.responseText)
    },
    complete: function () {
      spinner.addClass("hide")
      return btn_group.removeClass("hide")
    },
  })
}

update_submit_button = function (event) {
  var submitButton
  submitButton = $('button[data-toggle="update_repository_credentials"]')
  if ($(event.target).prop("checked")) {
    submitButton.attr(
      "data-confirm",
      "Are you sure you want to remove the repository credentials?"
    )
    return submitButton.attr("data-ok", "Yes, remove it")
  } else {
    submitButton.removeAttr(
      "data-confirm",
      "Are you sure you want to remove the repository credentials?"
    )
    return submitButton.removeAttr("data-ok", "Yes, remove it")
  }
}

$(function () {
  $(document).on("modal:contentUpdated", init_tag_editor_inputs)
  $(document).on(
    "change",
    'select[data-toggle="automationSwitch"]',
    switch_automation_type
  )
  $(document).on(
    "change",
    'select[data-toggle="selectAutomationInstance"]',
    select_automation_instance
  )
  $(document).on(
    "click",
    'a[data-toggle="run_automation_link"]',
    run_automation_link
  )
  $(document).on(
    "click",
    'input[type="checkbox"][data-toggle="update_repository_credentials"]',
    update_submit_button
  )
  return init_tag_editor_inputs()
})
