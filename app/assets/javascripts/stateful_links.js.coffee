# store current location
current_location = window.location
# store host
hostUrl = "#{window.location.protocol}//#{window.location.host}"
# store path
current_path = window.location.pathname
supportHistory = window.history.pushState && true

# This method returns a parameter value for a given parameter name.
getParameterByName= (url,name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(url)

  if results == null then "" else decodeURIComponent(results[1].replace(/\+/g, " "))

# This method checks if overlay parameter is presented and if so it tries to open the overlay.
handleUrl= (url) ->
  # check if overlay parameter is presented
  hidden = true

  if url.indexOf("?overlay=")>-1 or url.indexOf("&overlay=") >-1
    overlay = getParameterByName(url,'overlay');
    # build the href. If overlay value doesn't start with a "/" then
    # it is a relative url and should be extended with the current path.
    # e.g. new -> /current_path/new
    href = if overlay[0]=='/' then overlay else "#{current_path}/#{overlay}"
    # replace // with /
    href = href.replace(/\/\//g,'/')
    # look fo the anker with this href

    MoModal.load(href)
    hidden=false

  if hidden
    $('#modal-holder .modal').modal('hide')

# add overlay parameters to the current url
buildNewStateUrl= (href) ->
  href ||= ''
  # it is an absolute url if it contains the current path
  isAbsolutePath = (href.indexOf(current_path)==-1)
  # build href which will be shown in window address bar.
  # Idea:
  #  Case 1:
  #    base url: http://localhost:3000/sap_default/d064310_sandbox/instances
  #    link url: /sap_default/d064310_sandbox/instances/new
  #    -> overlay url (href): http://localhost:3000/sap_default/d064310_sandbox/instances/?overlay=new
  #  Case 2:
  #    base url: http://localhost:3000/sap_default/d064310_sandbox/instances/23/show
  #    link url: /sap_default/d064310_sandbox/instances/new
  #    -> overlay url (href): http://localhost:3000/sap_default/d064310_sandbox/instances/23/show?overlay=/sap_default/d064310_sandbox/instances/new

  href = href.replace(hostUrl,'').replace(current_path,'').replace(/^\/+/,'').trim()
  href = "/#{href}" if isAbsolutePath
  href = encodeURIComponent(href)

  if !supportHistory
    return "?overlay=#{href}"
  else
    current_url = current_location.href
    if current_url.indexOf("?")>=0
      overlayPos = current_url.indexOf('&overlay')
      current_url = current_url.substr(0,overlayPos) if overlayPos>-1
      current_url = current_url.slice(0,-1) if current_url and current_url[current_url.length-1]=='#'

      return "#{current_url}&overlay="+href
    else
      return "#{current_url}?overlay="+href

# remove overlay parameters from the current url
restoreOriginStateUrl= () ->
  if !supportHistory
    return current_path
  else
    current_url = current_location.href
    overlayPos = current_url.indexOf('?overlay')
    overlayPos = current_url.indexOf('&overlay') if overlayPos==-1
    current_url = current_url.substr(0,overlayPos) if overlayPos>-1

    return current_url

@restoreOriginStateUrl = () ->
  if supportHistory
    window.history.pushState(null, null, restoreOriginStateUrl())

# initialize modal links to change the window.location url
$(document).on 'click', 'a[data-modal=true]', ->
  if supportHistory
    window.history.replaceState(null, null, buildNewStateUrl(this.href))

$(document).ready ->
  # try to find the overlay parameter in the url and handle it if found.
  handleUrl(current_location.href) if supportHistory

  # reset history (url in address bar) after an overlay has been closed.
  $('#modal-holder').on 'hidden.bs.modal', '.modal', () ->
    if supportHistory
      window.history.replaceState(null, null, restoreOriginStateUrl())
