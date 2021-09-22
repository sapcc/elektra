// jQuery plugin

/**
 * Usage:
 *   add the attribute "data-sortable-columns" to a table with a string as value.
 *   The string should contain a list of indices separated by commas.
 *   It is also possible to determine which icons are used and which column is active.
 *
 *   Available icon types: string, number, amount
 *   active column is marked with "!" or "^". "!" means the column should be sorted initial.
 *
 * Example: <table data-sortable-columns="1:string,2^:number,3:amount,4">...</table>
 */

jQuery.fn.sortableTable = function (options) {
  options = options || {}
  var settings = $.extend({}, defaults, options)
  var defaults = {}

  var typeIcons = {
    string: {
      asc: "fa-sort-alpha-asc",
      desc: "fa-sort-alpha-desc",
      none: "fa-sort-alpha-asc",
    },
    number: {
      asc: "fa-sort-numeric-asc",
      desc: "fa-sort-numeric-desc",
      none: "fa-sort-numeric-asc",
    },
    default: { asc: "fa-sort-asc", desc: "fa-sort-desc", none: "fa-sort" },
    amount: {
      asc: "fa-sort-amount-asc",
      desc: "fa-sort-amount-desc",
      none: "fa-sort-amount-asc",
    },
  }

  function extractSortableColumns(dataString) {
    var result = {}
    dataString.split(",").forEach(function (item) {
      var data = item.split(":")
      var index = data[0].trim()
      var type = data[1] ? data[1].trim() : "default"

      var value = { type: type }

      if (index[index.length - 1] === "!" || index[index.length - 1] === "^") {
        value["active"] = index[index.length - 1]
        index = index.slice(0, -1)
      }

      result[parseInt(index) - 1] = value
    })
    return result
  }

  function sortTable(table, index, order, numeric) {
    var asc = order === "asc",
      tbody = table.find("tbody")

    var options = {}
    if (numeric) options.numeric = true

    // console.log("===", index, order, numeric, options)
    tbody
      .find("tr")
      .sort(function (a, b) {
        if (asc) {
          return $("td:eq(" + index + ")", a)
            .text()
            .localeCompare(
              $("td:eq(" + index + ")", b).text(),
              undefined,
              options
            )
        } else {
          return $("td:eq(" + index + ")", b)
            .text()
            .localeCompare(
              $("td:eq(" + index + ")", a).text(),
              undefined,
              options
            )
        }
      })
      .appendTo(tbody)
  }

  this.each(function () {
    var $table = $(this)
    var sortableColumns = extractSortableColumns(
      $table.attr("data-sortable-columns")
    )

    var allIcons = []
    var activeIndex
    var activeType
    $table.find("th").each(function (index, th) {
      if (sortableColumns[index]) {
        function makeSortable() {
          var data = sortableColumns[index]

          var active = data.active
          var type = data.type
          var icon = typeIcons[type] || {}
          var className = "fa"
          var order = "asc"

          if (active === "!") {
            activeIndex = index
            activeType = type
          }

          if (active) className += " " + icon.asc
          else className += " " + icon.none + " info-text"

          var sortIcon = $('<i class="' + className + '"></i>')
          allIcons.push(sortIcon)

          $(th)
            .css("cursor", "pointer")
            .click(function () {
              if (!sortIcon.hasClass("info-text")) {
                if (sortIcon.hasClass(icon.asc)) {
                  sortIcon.removeClass(icon.asc).addClass(icon.desc)
                  order = "desc"
                } else if (sortIcon.hasClass(icon.desc)) {
                  sortIcon.removeClass(icon.desc).addClass(icon.asc)
                  order = "asc"
                } else if (sortIcon.hasClass(icon.none)) {
                  sortIcon.removeClass(icon.none).addClass(icon.asc)
                }
              }

              allIcons.forEach(function (item) {
                item.addClass("info-text")
              })

              sortIcon.removeClass("info-text")

              sortTable(
                $table,
                index,
                order,
                type === "number" || type === "amount"
              )
            })

          $(th).append(" ").append(sortIcon)
        }

        makeSortable()
      }
    })

    if (activeIndex)
      sortTable(
        $table,
        activeIndex,
        "asc",
        activeType === "number" || activeType === "amount"
      )
  })
}
