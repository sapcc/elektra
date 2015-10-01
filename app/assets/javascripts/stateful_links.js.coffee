######################### VERSION 1 ##############################
# This version does not open overlay dynamically. It renders a static version of the overlay.
 
# # apply non-idempotent transformations to the body
# $(document).on 'ready', ->
#   # get current window location
#   current_location = window.location.href
#
#   # replace history state with current location
#   History.replaceState(current_location)
#
#   $('#modal-holder').on 'hidden.bs.modal', '.modal', ->
#     History.replaceState(null, null, current_location)
#
# # apply non-idempotent transformations to the document
# # initialize modal links. Push the url of the modal link to the history.
# $(document).on 'click', 'a[data-modal=true]', ->
#   History.replaceState(null, null, this.href)


#################### VERSION 2 ########################
# In this version overlay are opened automatically if overlay parameter is presented in the url.

History.options.html4Mode=true
# store current location 
current_location = window.location
# store host
hostUrl = "#{window.location.protocol}//#{window.location.host}"
# store path
path = window.location.pathname

# This method returns a parameter value for a given parameter name.
getParameterByName= (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  
  if results == null then "" else decodeURIComponent(results[1].replace(/\+/g, " "))

# This method checks if overlay parameter is presented and if so it tries to open the overlay. 
handleUrl= (url) ->
  #console.log 'handleUrl->url: ',url
  # check if overlay parameter is presented
  
  hidden = true
  
  if url.indexOf("?overlay=") > -1
    overlay = getParameterByName('overlay');
    # build the href. If overlay value doesn't start with a "/" then 
    # it is a relative url and should be extended with the current path.
    # e.g. new -> /current_path/new  
    href = if overlay[0]=='/' then overlay else "#{path}/#{overlay}" 
    # replace // with /
    href = href.replace(/\/\//g,'/')
    # look fo the anker with this href
    $anker = $("[href$='#{href}']")
    # if found then open the overlay. Otherwise hide current overlay
    if $anker.length>0 
      unless ($("#modal-holder .modal").data('bs.modal') || {}).isShown
        #console.log 'handleUrl->trigger click on ', href
        MoModal.load($anker)
        hidden=false
    
  if hidden 
    $('#modal-holder .modal').modal('hide')

click_drivern=false
# Bind to StateChange Event
History.Adapter.bind window,'statechange', -> # Note: We are using statechange instead of popstate
  State = History.getState() # Note: We are using History.getState() instead of event.state
  #console.log "click: ", click_drivern
  # do not handle the url if a link has been clicked. 
  # handle url only if history buttons of browser (back,next) were clicked.
  handleUrl(State.url) unless click_drivern
  click_drivern=false

# initialize modal links to change the window.location url
$(document).on 'click', 'a[data-modal=true]', ->
  # get current href value
  href = this.href || ''
  # it is an absolute url if it contains the current path
  isAbsolutePath = (this.href.indexOf(path)==-1)
  # build href which will be shown in window address bar.
  # Idea:
  #  Case 1: 
  #    base url: http://localhost:3000/sap_default/***REMOVED***_sandbox/instances
  #    link url: /sap_default/***REMOVED***_sandbox/instances/new
  #    -> overlay url (href): http://localhost:3000/sap_default/***REMOVED***_sandbox/instances/?overlay=new
  #  Case 2:
  #    base url: http://localhost:3000/sap_default/***REMOVED***_sandbox/instances/23/show
  #    link url: /sap_default/***REMOVED***_sandbox/instances/new
  #    -> overlay url (href): http://localhost:3000/sap_default/***REMOVED***_sandbox/instances/23/show?overlay=/sap_default/***REMOVED***_sandbox/instances/new 
  
  href = href.replace(hostUrl,'').replace(path,'').replace(/^\/+/,'').trim()
  href = "/#{href}" if isAbsolutePath

  click_drivern = true
  # push current href to the history (this chnages the url in address bar)
  History.pushState(null, null, "?overlay="+href)


$(document).ready ->
  # try to find the overlay parameter in the url and handle it if found.
  handleUrl(current_location.href)

  # reset history (url in address bar) after an overlay has been closed.
  $('#modal-holder').on 'hidden.bs.modal', '.modal', () ->
    History.pushState(null, null, current_location.pathname)



