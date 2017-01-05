#= require react/ajax_helper
#= require_tree .

((app)->
  app.ajaxHelper = new ReactAjaxHelper()

  app.getCurrentTabFromUrl=()->
    # check if tab uid is presented in url and update store if so.
    currentTab = window.location.hash.match(/#[^&]+/)
    if currentTab
      currentTab = currentTab[0].replace('#','')
    return currentTab

  app.setCurrentTabToUrl=(uid)->
    if window.location.hash.length>0
      window.location.hash = window.location.hash.replace(/#[^&]*/,uid)
    else
      window.location.hash = uid

)(shared_filesystem_storage)
