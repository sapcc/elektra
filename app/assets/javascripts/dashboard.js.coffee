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

  @hideModal: () ->
    $('#modal-holder .modal').modal('hide')


# define console if not exists (this is a case for IE)
if (typeof(window.console) == "undefined" || typeof(window.console.log) == "undefined")
  window.console = { log: () -> {} }


# -------------------------------------------------------------------------------------------------------------
# Initialize Dashboard App

$ ->
  # Tooltips
  $('abbr[title], abbr[data-original-title]').tooltip(delay: { "show": 300 })

  # init Form
  Dashboard.initForm()

  # update items which has the update attribute
  $('[data-update-url]').update()

  PollingService.init( selector: '*[data-update-path]', interval: 5)

  # initialize buttons with loading status
  $(document).on 'click', 'tr [data-loading-status]', () -> $(this).closest('tr').addClass('updating')
  $('tr [data-confirmed=loading_status]').attr('data-confirmed',"$(this).closest('tr').addClass('updating')")

  $("#accept_tos").click -> $("#register-button").prop('disabled', not $(this).prop('checked') )

  # init help hint popovers
  $('[data-toggle="popover"][data-popover-type="help-hint"]').popover
    placement: 'top'
    trigger: 'focus'

  # help text toggle
  $('[data-toggle="help"]').click (e) ->
    e.preventDefault()
    $('.plugin-help').toggleClass('visible')

  # ---------------------------------------------
  # Expandable Tree

  $('.tree-expandable .has-children > .node-icon').click (e) ->
    e.preventDefault()
    $(this).parent().toggleClass('node-expanded')


  # init all DOM elements found by css class '.searchable' as searchable
  $ -> $('.searchable').searchable()

  # show search form for searchable
  $('[data-trigger="show-searchable-search"]').click (e) ->
    $(this).toggleClass('active')
    $('.searchable-input').toggleClass('expanded').find('#search-input').focus()


# -------------------------------------------------------------------------------------------------------------
# Initialize Modal Windows          
$(document).on 'modal:contentUpdated', (e) ->
  $( "[data-autocomplete-url]" ).each () ->
    $input = $(this)
    $input.autocomplete({
      appendTo: $input.parent(),
      source: $input.data('autocompleteUrl'),
      select: ( event, ui ) ->
        $input.val(ui.item.name);
        return false;
    }).data('ui-autocomplete')._renderItem = ( ul, item ) ->
        return $( "<li>" )
          .attr( "data-value", item.name )
          .append( item.name )
          .appendTo( ul );
          
  try
    # define target selector dependent on id or class
    selector = "##{e.target.id}" if e.target.id
    selector = ".#{e.target.class}" if e.target.class
    # get form
    $form = $(selector).find('form')
    # find triger elements
    $form.find("select[data-trigger=change]").change Dashboard.showFormDetails

    # Dynamic Form - Hide/reveal parts of the form following a trigger event
    $form.find(".dynamic-form-trigger").change Dashboard.hideRevealFormParts
  catch error

  # init all DOM elements found by css class '.searchable' as searchable
  $("##{e.target.id} .searchable").searchable()

  $('[data-toggle="popover"][data-popover-type="help-hint"]').popover
    placement: 'top'
    trigger: 'focus'

  # -------------
  # init tooltips
  $('[data-toggle="tooltip"]').tooltip()

# # TURBOLINKS SUPPORT ---------------------------------------------------------------------
# # React to turbolinks page load events to indicate to the user that something is happening
# $ =>
#   startPageLoadIndicator = ->
#     $("html").css "cursor", "progress"
#     return
#
#   stopPageLoadIndicator = ->
#     $("html").css "cursor", "auto"
#     return
#
#
#   $(document).on "page:fetch", startPageLoadIndicator
#   $(document).on "page:receive", stopPageLoadIndicator
