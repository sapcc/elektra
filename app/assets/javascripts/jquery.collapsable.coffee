
class Collapsable
  constructor: (elem, options) ->
    @options = options || {}
    @$content = $(elem)
    @buildCollapseContainer()


  buildCollapseContainer: () ->
    console.log @options
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
