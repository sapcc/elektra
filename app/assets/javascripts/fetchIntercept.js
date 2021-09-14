// "use strict"

// window.activeAjaxCallsCount = window.activeAjaxCallsCount || 0

// // window.activeAjaxCallsCount is used in e2e tests
// // intercept fetch and handle the count, increase before start ajax call
// // and decrease after done.
// var origFetch = window.fetch
// window.fetch = async function () {
//   window.activeAjaxCallsCount += 1
//   return origFetch.apply(undefined, arguments).finally(function () {
//     window.activeAjaxCallsCount -= 1
//   })
// }

"use strict"

var _arguments = arguments

function _asyncToGenerator(fn) {
  return function () {
    var gen = fn.apply(this, arguments)
    return new Promise(function (resolve, reject) {
      function step(key, arg) {
        try {
          var info = gen[key](arg)
          var value = info.value
        } catch (error) {
          reject(error)
          return
        }
        if (info.done) {
          resolve(value)
        } else {
          return Promise.resolve(value).then(
            function (value) {
              return step("next", value)
            },
            function (err) {
              return step("throw", err)
            }
          )
        }
      }
      return step("next")
    })
  }
}

window.activeAjaxCallsCount = window.activeAjaxCallsCount || 0

// window.activeAjaxCallsCount is used in e2e tests
// intercept fetch and handle the count, increase before start ajax call
// and decrease after done.
var origFetch = window.fetch
window.fetch = (function () {
  var ref = _asyncToGenerator(
    regeneratorRuntime.mark(function _callee() {
      var _args = _arguments
      return regeneratorRuntime.wrap(
        function _callee$(_context) {
          while (1) {
            switch ((_context.prev = _context.next)) {
              case 0:
                window.activeAjaxCallsCount += 1
                return _context.abrupt(
                  "return",
                  origFetch.apply(undefined, _args).finally(function () {
                    window.activeAjaxCallsCount -= 1
                  })
                )

              case 2:
              case "end":
                return _context.stop()
            }
          }
        },
        _callee,
        undefined
      )
    })
  )

  return function (_x) {
    return ref.apply(this, arguments)
  }
})()
