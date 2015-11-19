$.fn.initLoadingSection = () ->
  this.each () ->
    $element = $(this)

    target = $element.data('loadingTargetId')
    if typeof target == "undefined"
      return

    text = $element.data('loadingText')
    if typeof text == "undefined"
      text = "Retrieving data..."

    $("#"+target).append('<span>' + text + '</span><span class="loading-spinner-section"></span>')
    $("#"+target).addClass('hidden')

    $element.click ->
      $("#"+target).removeClass('hidden')
      $('html, body').animate({ scrollTop: $("#"+target).offset().top }, 500)
      return

    return this


$ ->
# -----------
# Automation
# -----------
  $('.loading_section').initLoadingSection()

