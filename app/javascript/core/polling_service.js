/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// this class implements the polling service
var PollingService = (function () {
  let selector = undefined
  let interval = undefined
  let updateElement = undefined
  let update = undefined
  PollingService = class PollingService {
    static initClass() {
      selector = null
      interval = null

      updateElement = function (element) {
        const $element = $(element)

        // Ignore update if update already in the update queue
        if ($element.data("queuedForPolling") === true) {
          return
        }

        // Ignore update if element disabled
        if ($element.data("pollingIsDisabled") === true) {
          return
        }

        $element.data("queuedForPolling", true)
        const url = $element.data("updatePath")
        if (!url) {
          return
        }
        const dataType = url.search(/^[^?]+\.js/) >= 0 ? "script" : "html"

        return $.ajax({
          url,
          dataType,
          data: { polling_service: true },
          success(data, textStatus, jqXHR) {
            // try to get loacation from response header
            const redirectTo = jqXHR.getResponseHeader("Location")
            // response is a redirect
            if (redirectTo) {
              // redirect url is equal to auth path
              if (redirectTo.indexOf("/auth/login/") > -1) {
                // just reload to avoid redirect to a no layout page after login
                return window.location.reload()
              } else {
                // redirect to the redirectTo url
                return (window.location = redirectTo)
              }
            } else {
              // no redirect -> replace content with html from response
              const ct = jqXHR.getResponseHeader("content-type") || ""
              if (ct.indexOf("javascript") > -1) {
                return eval(data)
              } else {
                return $element.replaceWith(data)
              }
            }
          },

          error() {},
          complete() {
            $element.data("queuedForPolling", false)
            return $("body").trigger("polling:update_complete")
          },
        })
      }

      // update method which is called periodically
      update = function () {
        // get current timestamp
        const timestamp = Math.round(new Date().getTime() / 1000)

        // for each element found by selector do
        return $(selector).each(function () {
          const $element = $(this)

          // element's own update interval
          let updateInterval = $element.data("updateInterval") || 10
          updateInterval = updateInterval * 1000

          // modulo operation: rest of current timestamp divided by element's interval should be zero
          const shouldUpdate =
            timestamp % Math.round(updateInterval / interval) === 0
          if (shouldUpdate) {
            return updateElement($element)
          }
        })
      }
    }

    // initialize the service
    static init(options) {
      // selector is a string which identifies DOM elements to be updated
      if (options == null) {
        options = {}
      }
      selector = options["selector"]

      // update elements immediately if they have the corresponding attribute
      $(`${selector}[data-update-immediately='true']`).each(function () {
        return updateElement(this)
      })

      // Interval in seconds or milliseconds between polling calls.
      // The polling service runs regularly and tries to update all the elements found by selector.
      // Each element (found by selector) can define its own interval. The element is only updated
      // if its interval is correlated with the polling interval.
      interval = options["interval"] || 10
      if (interval < 1000) {
        interval = interval * 1000
      }

      // start update with interval
      return setInterval(update, interval)
    }

    // fire an update event. All elements which data-update-path matches the given name will be updated!
    // For example, update('inquiries') will update data-update-path='inquiriy/inquiries/list'.
    static update(name) {
      return $(`*[data-update-path*='${name}']`).each(function () {
        return updateElement(this)
      })
    }

    // Pop element from the update queue.
    // Element selector -> css selector
    static disableElement(elementSelector) {
      return $(elementSelector).data("pollingIsDisabled", true)
    }

    // Push element to the update queue.
    // Element selector -> css selector
    static enableElement(elementSelector) {
      return $(elementSelector).data("pollingIsDisabled", false)
    }
  }
  PollingService.initClass()
  return PollingService
})()

window.PollingService = PollingService
