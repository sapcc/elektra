window.activeAjaxCallsCount = window.activeAjaxCallsCount || 0

// window.activeAjaxCallsCount is used in e2e tests
// intercept fetch and handle the count, increase before start ajax call
// and decrease after done.
var origFetch = window.fetch
window.fetch = async (...args) => {
  window.activeAjaxCallsCount += 1
  return origFetch(...args).finally(() => {
    window.activeAjaxCallsCount -= 1
  })
}
