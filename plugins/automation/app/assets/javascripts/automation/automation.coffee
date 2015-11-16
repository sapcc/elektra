$.fn.initLoadingSection = () ->
  this.each () ->
    $element = $(this)
    target = $element.data('loadingTargetId')
    text = $element.data('loadingText')
    $("#"+target).append('<span>' + text + '</span><span class="loading-spinner"></span>')
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

