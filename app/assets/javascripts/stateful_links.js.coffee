# function getParameterByName(name) {
#   name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
#   var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
#       results = regex.exec(location.search);
#   return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
# }
# 
# function handleUrl(url){
#   if (url.indexOf("?vstate=") > -1) {
#     var vstate = getParameterByName('vstate');
#     console.log(vstate)
#     var $anker = $("[href='"+vstate+"']")
#     console.log($anker)
#     if ($anker.length>0) {
#       $anker.trigger('click')
#     }
#   }
# }
# 
# # Bind to StateChange Event
# History.Adapter.bind(window,'statechange',function(){ # Note: We are using statechange instead of popstate
#   var State = History.getState(); # Note: We are using History.getState() instead of event.state
#   console.log("History: statechange")
#   handleUrl(State.url);
# });
# 
# $(document).ready(function(){
#   var State = History.getState(); # Note: We are using History.getState() instead of event.state
#   handleUrl(State.url);
# 
#   $("[data-modal='true']").click(function(){
#     console.log($(this),$(this).first())
#     History.pushState(null, null, "?vstate="+$(this).attr("href"));
#   });
# 
#   $('#modal-holder').on('hidden.bs.modal', '.modal',function () {
#     console.log('hidden')
#     History.pushState(null, null, State.url);
#     //History.back();
#   });
# });


# apply non-idempotent transformations to the body
$(document).on 'ready', ->
  # get current window location
  current_location = window.location.href
    
  # replace history state with current location
  History.replaceState(current_location)
  
  $('#modal-holder').on 'hidden.bs.modal', '.modal', ->
    History.replaceState(null, null, current_location)
  
# apply non-idempotent transformations to the document
# initialize modal links. Push the url of the modal link to the history.
$(document).on 'click', 'a[data-modal=true]', ->
  History.replaceState(null, null, this.href)
