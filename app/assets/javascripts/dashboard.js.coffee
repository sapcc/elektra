class @Dashboard
  @hideRevealFormParts: () ->
    allTargets  = $(".dynamic-form-target")
    target      = allTargets.filter("*[data-type='" + $(this).val() + "']") # from all targets select the one that matches the value that's been selected with the trigger
  
    # find all targets, hide them, set descendants that are any kind of form input to disabled (to prevent them getting submitted when the form is posted)
    allTargets.hide().find(":input").prop("disabled", true)
  
    # show the target that's been selected by the trigger, enable all descendants that are inputs
    target.show().find(":input").prop("disabled", false)
  
  @jsSubmitButton: (element, selector) -> $(element).closest(selector).find('form').submit()


$(document).on 'ready page:load', ->  
  $(".toggle-debug").click (e) ->
    e.preventDefault()
    $(".debug-info").toggleClass("visible")

  # Interactive page elements #
  
  # -----------
  # Hidden form
  # -----------
  $(".js-trigger-hiddenform").click (e) ->
    e.preventDefault()
    $(this).hide()
    $(".js-target-hiddenform").show()

  $(".js-cancel-hiddenform").click (e) ->
    e.preventDefault()
    $(".js-target-hiddenform").hide()
    $(".js-trigger-hiddenform").show()

    
  # Dynamic Form - Hide/reveal parts of the form following a trigger event
  $(".dynamic-form-trigger").change Dashboard.hideRevealFormParts
  
  # initialize js submit buttons
  $("*[data-js-submit]").click (e) -> Dashboard.jsSubmitButton(this,$(this).data('js-submit'))

