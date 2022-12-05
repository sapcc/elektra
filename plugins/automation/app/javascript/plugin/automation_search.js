var AutomationSearch

AutomationSearch = (function () {
  var buildUrl, dimmArea, filter, search

  function AutomationSearch(options) {
    this.el = options.el
    this.initialize(options)
  }

  AutomationSearch.prototype.initialize = function (options1) {
    this.options = options1
    this.searchDimmedArea = this.el.data("search-dimmed-area")
    this.searchRenderArea = this.el.data("search-render-area")
    this.searchErrorArea = this.el.data("search-error-area")
    $("." + this.searchDimmedArea).prepend(
      '<span class="search-spinner hide"></p>'
    )
    return this.el.find("form").on("submit", $.proxy(search, this))
  }

  search = function (e) {
    var searchUrl, searchValue, searchbaseUrl
    e.stopPropagation()
    e.preventDefault()
    searchbaseUrl = $(e.target).attr("action")
    searchValue = this.el.find("input#js-search_input").val()
    $("." + this.searchErrorArea).html("")
    searchUrl = buildUrl(searchbaseUrl, "search_service", true)
    searchUrl = buildUrl(searchUrl, "search", searchValue)
    dimmArea(this, true)
    return filter(this, searchUrl, 0)
  }

  filter = function (_this, searchUrl, timeout) {
    var $this
    $this = _this
    return setTimeout(
      (function (_this) {
        return function () {
          return $.get(searchUrl)
            .done(function (data, status, xhr) {
              dimmArea($this, false)
              $("." + $this.searchRenderArea).html(data)
              return $(
                '[data-toggle="paginationSpinner"]'
              ).initPaginationSpinner()
            })
            .fail(function () {
              dimmArea($this, false)
              return $("." + $this.searchErrorArea).html(
                "Search error. Try again later."
              )
            })
        }
      })(this),
      timeout
    )
  }

  dimmArea = function (_this, shouldDimm) {
    if (_this.searchDimmedArea !== "") {
      if (shouldDimm) {
        _this.el.find("input").attr("disabled", "disabled")
        _this.el.find("button[type=submit]").attr("disabled", "disabled")
        $("." + _this.searchDimmedArea).addClass("dimmed")
        return $("." + _this.searchDimmedArea)
          .find(".search-spinner")
          .removeClass("hide")
      } else {
        _this.el.find("input").removeAttr("disabled")
        _this.el.find("button[type=submit]").removeAttr("disabled", "disabled")
        $("." + _this.searchDimmedArea).removeClass("dimmed")
        return $("." + _this.searchDimmedArea)
          .find(".search-spinner")
          .addClass("hide")
      }
    }
  }

  buildUrl = function (base, key, value) {
    var sep
    if (typeof base === "undefined") {
      base = ""
    }
    sep = base.indexOf("?") > -1 ? "&" : "?"
    return base + sep + key + "=" + value
  }

  return AutomationSearch
})()

$.fn.initAutomationSearch = function (options) {
  options = options || {}
  return this.each(function () {
    options.el = $(this)
    return new AutomationSearch(options)
  })
}

$(function () {
  $(document).on("modal:contentUpdated", function () {
    return $('[data-toggle="automationSearch"]').initAutomationSearch()
  })
  return $('[data-toggle="automationSearch"]').initAutomationSearch()
})
