class InlineFormNodeTag

  # The default constructor calls the initialize method and set the jQuery element.
  # Remember to call super in subclasses if you want to maintain this behaviour.
  constructor: (options) ->
    @el = options.el
    @initialize options

  # Method to initialize the plugin instance with the given options
  # This method could be called
  initialize: (@options) ->
    @el.find('.js-node-tags-link-edit').click (event) =>
      # reset the original state just when clicking edit
      @el.find('.js-node-input-tags').val(@el.find('.js-node-tags-read').data('node-form-read'))
      @edit_mode()
      event.stopPropagation()
    @el.find('.js-node-tags-link-cancel').click (event) =>
      @read_mode()
      event.stopPropagation()

    if @options['state'] == 'open'
      @edit_mode()
    else
      @read_mode()

  read_mode: () ->
    # remove the tag editor
    @el.find('ul.tag-editor').remove()
    # show and hide
    @el.find('.js-node-tags-link-edit').removeClass('hide')
    @el.find('.js-node-tags-icon-read').addClass('hide')
    @el.find('.js-node-tags-edit').addClass('hide')
    @el.find('.js-node-tags-read').removeClass('hide')

  edit_mode: () ->
    # init the tag editor tool
    @el.find('.js-node-input-tags').tagEditor({ placeholder: $(this).attr('placeholder') || 'Enter key value pairs', maxLength: 255, delimiter: '¡' })
    # show and hide stuff
    @el.find('.js-node-tags-link-edit').addClass('hide')
    @el.find('.js-node-tags-icon-read').removeClass('hide')
    @el.find('.js-node-tags-edit').removeClass('hide')
    @el.find('.js-node-tags-read').addClass('hide')

$.fn.initInlineFormNodeTag = (options) ->
  options = options || {}
  this.each () ->
    options.el = $(this)
    new InlineFormNodeTag(options)

$ ->
  $(document).on 'modal:contentUpdated', ->
    $('.js-inline-form-node-tags').initInlineFormNodeTag()

  $('.js-inline-form-node-tags').initInlineFormNodeTag()
