import Clipboard from "clipboard"

$.fn.initSnippetCopyToClipboard = () ->
  this.each () ->
    $element = $(this)

    if $element.find('button[data-clipboard-snippet]').length > 0
      return

    # add copy button
    $element.prepend('<button class="btn btn-default btn-icon-only" data-clipboard-snippet><i class="fa fa-clipboard"></i></button>')
    button = $element.find('[data-clipboard-snippet]')
    # add click event
    button.on 'click', (e) ->
      e.preventDefault()

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
  elem.setAttribute 'data-trigger', 'manual'
  elem.setAttribute 'title', msg
  $(elem).tooltip('show')

  # leave tooltip for 1 sec then clean up and hide
  setTimeout((() =>
    $(elem).tooltip('hide')
    elem.setAttribute 'title', ''
    $(elem).blur()
    ), 1000)

  return

$ ->
  $('.snippet').initSnippetCopyToClipboard()
