JsHelpers = {}

JsHelpers.fileDownload = (data, filename, mime) ->
  # JS File Download from https://github.com/kennethjiang/js-file-download
  blob = new Blob([ data ], type: mime or 'application/octet-stream')
  if typeof window.navigator.msSaveBlob != 'undefined'
    # IE workaround for "HTML7007: One or more blob URLs were
    # revoked by closing the blob for which they were created.
    # These URLs will no longer resolve as the data backing
    # the URL has been freed."
    window.navigator.msSaveBlob blob, filename
  else
    blobURL = window.URL.createObjectURL(blob)
    tempLink = document.createElement('a')
    tempLink.style.display = 'none'
    tempLink.href = blobURL
    tempLink.setAttribute 'download', filename
    # Safari thinks _blank anchor are pop ups. We only want to set _blank
    # target if the browser does not support the HTML5 download attribute.
    # This allows you to download files in desktop safari if pop up blocking
    # is enabled.
    if typeof tempLink.download == 'undefined'
      tempLink.setAttribute 'target', '_blank'
    document.body.appendChild tempLink
    tempLink.click()
    document.body.removeChild tempLink
    window.URL.revokeObjectURL blobURL
  return



@JsHelpers = JsHelpers
