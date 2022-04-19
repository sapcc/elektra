class ReactAjaxHelper
  constructor: (rootUrl, options={}) ->
    @rootUrl = rootUrl
    unless @rootUrl
      l = window.location
      @rootUrl = "#{l.protocol}//#{l.host}/#{l.pathname}"

    @authToken = options['authToken']

  @request: (url, method, options={}) ->
    url = url.replace(/([^:]\/)\/+/g, "$1")
    formattedData = if options['contentType'] then JSON.stringify(options['data']) else options['data']
    $.ajax
      url: url
      method: method
      headers:
        "X-Auth-Token": options['authToken'] if options['authToken']
      dataType: options['dataType'] if options['dataType']
      contentType: options['contentType'] || 'application/x-www-form-urlencoded'
      data: formattedData
      success: options['success']
      error: options['error']
      statusCode: options['statusCode']
      complete: ( jqXHR, textStatus) ->
        redirectToUrl = jqXHR.getResponseHeader('Location')
        if redirectToUrl # url is presented
          # Redirect to url
          currentUrl = encodeURIComponent(window.location.href)
          redirectToUrl = redirectToUrl.replace(/after_login=(.*)/g,"after_login=#{currentUrl}")
          window.location = redirectToUrl
        else
          options['complete'](jqXHR, textStatus) if options["complete"]

  get: (path,options={}) -> ReactAjaxHelper.request(@rootUrl+path,'GET',ReactHelpers.mergeObjects(options, {'authToken': @authToken}))
  post: (path,options={}) -> ReactAjaxHelper.request(@rootUrl+path,'POST',ReactHelpers.mergeObjects(options, {'authToken': @authToken}))
  put: (path,options={}) -> ReactAjaxHelper.request(@rootUrl+path,'PUT',ReactHelpers.mergeObjects(options, {'authToken': @authToken}))
  delete: (path,options={}) -> ReactAjaxHelper.request(@rootUrl+path,'DELETE',ReactHelpers.mergeObjects(options, {'authToken': @authToken}))

window.ReactAjaxHelper = ReactAjaxHelper