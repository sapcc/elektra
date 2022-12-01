/* eslint-disable no-undef */
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const polling_update_url_count = {}
const polling_update_interval = 30000

$.fn.update = function () {
  return this.each(function () {
    const $element = $(this)

    // data-updateUrl is set by server
    const url = $element.data("updateUrl")
    // return if no update url defined
    if (!url) {
      return this
    }

    polling_update_url_count[url] = (polling_update_url_count[url] || 0) + 1
    const count = polling_update_url_count[url]
    if (count * polling_update_interval > 5 * 60 * 1000) {
      return
    }

    const interval = $element.data("interval") || polling_update_interval

    setTimeout(
      () =>
        $.ajax({
          url,
        }),

      // success: (newItem) ->
      //   $newItem = $(newItem)
      //   $element.replaceWith($newItem)
      //   $newItem.update()
      interval
    )

    return this
  })
}
