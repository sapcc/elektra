class @Dashboard
  @hideRevealFormParts: () ->
    allTargets  = $(".dynamic-form-target")
    target      = allTargets.filter("*[data-type='" + $(this).val() + "']") # from all targets select the one that matches the value that's been selected with the trigger

    # find all targets, hide them, set descendants that are any kind of form input to disabled (to prevent them getting submitted when the form is posted)
    allTargets.hide().find(":input").prop("disabled", true)

    # show the target that's been selected by the trigger, enable all descendants that are inputs
    target.show().find(":input").prop("disabled", false)

  @showFormDetails: () ->
    target = $(this).data('target')
    $(target).addClass("hidden")
    $("#{target}##{this.value}").removeClass("hidden")
      
  @initForm: () ->
    # flavor details
    $("form select[data-trigger=change]").change Dashboard.showFormDetails
    # Dynamic Form - Hide/reveal parts of the form following a trigger event
    $(".dynamic-form-trigger").change Dashboard.hideRevealFormParts
    

$(document).on 'ready page:load', ->
  
  # -----------
  # Tooltips
  # -----------
  $('abbr[title], abbr[data-original-title]').tooltip(delay: { "show": 300 })
  
  # init Form
  Dashboard.initForm()
