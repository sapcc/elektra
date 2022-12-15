/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import ReactHelpers from "./helpers"
class ReactAjaxHelper {
  constructor(rootUrl, options) {
    if (options == null) {
      options = {}
    }
    this.rootUrl = rootUrl
    if (!this.rootUrl) {
      const l = window.location
      this.rootUrl = `${l.protocol}//${l.host}/${l.pathname}`
    }

    this.authToken = options["authToken"]
  }

  static request(url, method, options) {
    if (options == null) {
      options = {}
    }
    url = url.replace(/([^:]\/)\/+/g, "$1")
    const formattedData = options["contentType"]
      ? JSON.stringify(options["data"])
      : options["data"]
    return $.ajax({
      url,
      method,
      headers: options["authToken"]
        ? { "X-Auth-Token": options["authToken"] }
        : undefined,
      dataType: options["dataType"] ? options["dataType"] : undefined,
      contentType:
        options["contentType"] || "application/x-www-form-urlencoded",
      data: formattedData,
      success: options["success"],
      error: options["error"],
      statusCode: options["statusCode"],
      complete(jqXHR, textStatus) {
        let redirectToUrl = jqXHR.getResponseHeader("Location")
        if (redirectToUrl) {
          // url is presented
          // Redirect to url
          const currentUrl = encodeURIComponent(window.location.href)
          redirectToUrl = redirectToUrl.replace(
            /after_login=(.*)/g,
            `after_login=${currentUrl}`
          )
          return (window.location = redirectToUrl)
        } else {
          if (options["complete"]) {
            return options["complete"](jqXHR, textStatus)
          }
        }
      },
    })
  }

  get(path, options) {
    if (options == null) {
      options = {}
    }
    return ReactAjaxHelper.request(
      this.rootUrl + path,
      "GET",
      ReactHelpers.mergeObjects(options, { authToken: this.authToken })
    )
  }
  post(path, options) {
    if (options == null) {
      options = {}
    }
    return ReactAjaxHelper.request(
      this.rootUrl + path,
      "POST",
      ReactHelpers.mergeObjects(options, { authToken: this.authToken })
    )
  }
  put(path, options) {
    if (options == null) {
      options = {}
    }
    return ReactAjaxHelper.request(
      this.rootUrl + path,
      "PUT",
      ReactHelpers.mergeObjects(options, { authToken: this.authToken })
    )
  }
  delete(path, options) {
    if (options == null) {
      options = {}
    }
    return ReactAjaxHelper.request(
      this.rootUrl + path,
      "DELETE",
      ReactHelpers.mergeObjects(options, { authToken: this.authToken })
    )
  }
}

export default ReactAjaxHelper
