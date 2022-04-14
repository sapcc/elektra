job_popover_matcher = '[data-toggle="popover"][data-popover-type="job-history"]'

init_history_popover= () ->
  # init popovers elements
  init_job_popover()

init_job_popover= () ->
  # init the popover
  $(job_popover_matcher).popover
    placement: 'top'
    html: true
    container: '.js-nodes-table'

  # add click handler to the popovers to hide popover if other popover is clicked
  $(job_popover_matcher).on 'click', job_popover_close_other_popovers_handler

  # add click handler to close the jobs popover when shown
  $(job_popover_matcher).on 'shown.bs.popover', ->
    $('.js-close-popover').on 'click', close_popover

  # add click handler to the html element to close popovers when clicking outside of the elements
  $('html').unbind('click', job_popover_outside_click_handler)
  if $(job_popover_matcher).length > 0
    $('html').bind('click', job_popover_outside_click_handler)

close_popover= () ->
  $(job_popover_matcher).popover 'hide'

job_popover_close_other_popovers_handler= (e) ->
  e.stopPropagation()
  e.preventDefault()
  $(job_popover_matcher).not(this).popover 'hide'

job_popover_outside_click_handler= (e) ->
  if $(e.target).data('popover-type') != 'job-history' and $(e.target).parents('.popover.in').length == 0
    close_popover()

$ ->
  # add handlers to the polling update event
  $(document).on('polling:update_complete',init_history_popover)


  # init history popovers elements
init_job_popover()
