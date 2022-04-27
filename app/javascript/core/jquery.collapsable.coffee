
class Collapsable
  constructor: (elem, options) ->
    @options = options || {}
    @$content = $(elem)
    return if @$content.data('registered')
    @$content.data('registered', true)

    lineHeight = try
      parseInt(@$content.css('lineHeight'))
    catch error
      20

    height = try
      @$content.height()
    catch error
      30

    # console.log 'lineHeight', lineHeight
    # console.log 'height', height


    @buildCollapseContainer() if height > lineHeight*2

  buildCollapseContainer: () ->
    collapsed = if @options.hasOwnProperty('collapsed')
      @options.collapsed
    else
      @$content.is('[data-collapsed]')

    @$content.wrap('<div class="collapsable '+('collapsed' if collapsed)+'"></div>')
             .addClass('collapsable-content')

    $toggleButton = $('<a href="#" class="collapsable-toggle-button"><i></i></a>')
      .insertBefore(@$content)
      # .click (e) =>
      #   e.preventDefault()
      #   @$content.closest('.collapsable').toggleClass('collapsed')

    $container = @$content.closest('.collapsable')
    $container.click (e) =>
      e.preventDefault()
      $container.toggleClass('collapsed')

$.fn.collapsable = (options={}) ->
  this.each (index, elem) -> new Collapsable(elem, options)
