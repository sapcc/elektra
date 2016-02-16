#= require clipboard.min

$.fn.initSnippetCopyToClipboard = () ->
  this.each () ->
    $element = $(this)
    $element.prepend('<button class="btn btn-default" data-clipboard-snippet><i class="fa fa-clipboard"></i></button>')

    clipboardSnippets = new Clipboard('[data-clipboard-snippet]', target: (trigger) ->
      $(trigger).siblings( "code" ).get(0)
    )

    clipboardSnippets.on 'success', (e) ->
      e.clearSelection()
      showTooltip e.trigger, 'Copied!'
      return

    clipboardSnippets.on 'error', (e) ->
      showTooltip e.trigger, fallbackMessage(e.action)
      return

showTooltip = (elem, msg) ->
  elem.setAttribute 'data-toggle', 'tooltip'
  elem.setAttribute 'data-placement', 'bottom'
  elem.setAttribute 'title', msg
  $(elem).tooltip(delay: {"hide": 1000 })
  $(elem).tooltip('show')
  $(elem).on 'hidden.bs.tooltip', ->
    $(this).tooltip('destroy')
    $(this).blur()
  return

$ ->
  $('.snippet').initSnippetCopyToClipboard()