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

# init help hint popovers
@initHelpHint= () ->
  # https://stackoverflow.com/questions/32911355/whats-the-tabindex-1-in-bootstrap-for
  $('[data-toggle="popover"][data-popover-type="help-hint"]').attr("tabindex","0")
  $('[data-toggle="popover"][data-popover-type="help-hint"]').popover
    placement: 'top'
    trigger: 'focus'

$ ->
  # enter the cloud on enter key
  $enterCloudButton = $('#enter_the_cloud_button')
  if $enterCloudButton.length>0
    $(document).keyup (e) ->
      code = e.which
      if code==13
        e.preventDefault()
        window.location = $enterCloudButton.attr('href');


  # Tooltips
  $('abbr[title], abbr[data-original-title]').tooltip(delay: { "show": 300 })
  # init tooltips
  $('[data-toggle="tooltip"]').tooltip()

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
  initHelpHint()

  # help text toggle
  $('[data-toggle="help"]').click (e) ->
    e.preventDefault()
    $('.plugin-help').toggleClass('visible')

  # generic visibility toggle
  $('[data-action="toggle"]').click (e) ->
    e.preventDefault()
    $($(this).attr('data-target')).toggleClass('hidden')


  # init universal search input field
  $('[data-universal-search-field]').keyup (event) ->
    if event.keyCode == 13
      $(this)
        .attr('disabled',true)
        .closest('.has-feedback')
        .find('.fa-search').removeClass('fa-search').addClass('spinner')

      url = $(this).data('url')+'#/universal-search'
      window.location.href = url+'?searchTerm='+this.value
      # the pathname didn't change -> reload page with new search term param
      window.location.reload() if window.location.href.indexOf(url) >= 0
  # ---------------------------------------------
  # Expandable Tree

  $('.tree-expandable .has-children > .node-icon').click (e) ->
    e.preventDefault()
    $(this).parent().toggleClass('node-expanded')


  # init all DOM elements found by css class '.searchable' as searchable
  $ -> $('.searchable').searchable()

  # ajax paginate
  $ -> $('*[data-ajax-paginate]').ajaxPaginate()

  # show search form for searchable
  $('[data-trigger="show-searchable-search"]').click (e) ->
    $(this).toggleClass('active')
    $('.searchable-input').toggleClass('expanded').find('#search-input').focus()


  # $('[data-collapsable]').collapsable()
  # make tables sortable
  $ -> $('table[data-sortable-columns]').sortableTable()


# use MutationObserver to make new added nodes collapsable
observer = new MutationObserver (mutations) ->
  for mutation in mutations
    if (mutation.type == 'childList')
      collapsable_containers = $(mutation.addedNodes).find('[data-collapsable]')
      if collapsable_containers && collapsable_containers.length > 0
        collapsable_containers.collapsable()

      multiselect_boxes = $(mutation.addedNodes).find('[data-multiselect-box]')

      if multiselect_boxes && multiselect_boxes.length > 0
        multiselect_boxes.multiselect
          numberDisplayed: 1


observer.observe(document.documentElement, {childList: true, subtree: true});
# -------------- END

# -------------------------------------------------------------------------------------------------------------
# Initialize Modal Windows
$(document).on 'modal:contentUpdated', (e) ->
  try
    # define target selector dependent on id or class
    selector = "##{e.target.id}" if e.target.id
    selector = ".#{e.target.class}" if e.target.class
    # get form
    $form = $(selector).find('form')
    # find triger elements
    $form.find("select[data-trigger=change]").change Dashboard.showFormDetails

    # $(selector).find('[data-collapsable]').collapsable()

    # Dynamic Form - Hide/reveal parts of the form following a trigger event
    $form.find(".dynamic-form-trigger").change Dashboard.hideRevealFormParts


    $(selector).find("[data-autocomplete-url]" ).each () ->
      $input = $(this)
      valueAttr = $input.data('autocompleteValue') || 'id'
      labelAttr = $input.data('autocompleteLabel') || 'name'
      detailsAttr = $input.data('autocompleteDetails') || 'id'

      $input.autocomplete({
        appendTo: $input.parent(),
        source: $input.data('autocompleteUrl'),
        select: ( event, ui ) ->
          $input.attr("data-autocomplete-value",ui.item[valueAttr])
          $input.val(ui.item.name);
          return false;
      }).data('ui-autocomplete')._renderItem = ( ul, item ) ->
          return $( "<li>" )
            .attr( "data-value", item[valueAttr] )
            .text(item[labelAttr])
            .append( "<br/><span class='info-text'>#{item[detailsAttr]}</span>" )
            .appendTo( ul );

  catch error

  # init all DOM elements found by css class '.searchable' as searchable
  $("##{e.target.id} .searchable").searchable()

  # init help hint popovers
  initHelpHint()

  # -------------
  # init tooltips
  $('[data-toggle="tooltip"]').tooltip()


  # generic visibility toggle
  $('[data-action="toggle"]').click (e) ->
    e.preventDefault()
    $($(this).attr('data-target')).toggleClass('hidden')


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
