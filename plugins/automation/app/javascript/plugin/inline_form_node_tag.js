var InlineFormNodeTag

InlineFormNodeTag = (function () {
  function InlineFormNodeTag(options) {
    this.el = options.el
    this.initialize(options)
  }

  InlineFormNodeTag.prototype.initialize = function (options1) {
    this.options = options1
    this.el.find(".js-node-tags-link-edit").click(
      (function (_this) {
        return function (event) {
          _this.el
            .find(".js-node-input-tags")
            .val(_this.el.find(".js-node-tags-read").data("node-form-read"))
          _this.edit_mode()
          return event.stopPropagation()
        }
      })(this)
    )
    this.el.find(".js-node-tags-link-cancel").click(
      (function (_this) {
        return function (event) {
          _this.read_mode()
          return event.stopPropagation()
        }
      })(this)
    )
    if (this.options["state"] === "open") {
      return this.edit_mode()
    } else {
      return this.read_mode()
    }
  }

  InlineFormNodeTag.prototype.read_mode = function () {
    this.el.find("ul.tag-editor").remove()
    this.el.find(".js-node-tags-link-edit").removeClass("hide")
    this.el.find(".js-node-tags-icon-read").addClass("hide")
    this.el.find(".js-node-tags-edit").addClass("hide")
    return this.el.find(".js-node-tags-read").removeClass("hide")
  }

  InlineFormNodeTag.prototype.edit_mode = function () {
    this.el.find(".js-node-input-tags").tagEditor({
      placeholder: $(this).attr("placeholder") || "Enter key value pairs",
      maxLength: 255,
      delimiter: "¡",
    })
    this.el.find(".js-node-tags-link-edit").addClass("hide")
    this.el.find(".js-node-tags-icon-read").removeClass("hide")
    this.el.find(".js-node-tags-edit").removeClass("hide")
    return this.el.find(".js-node-tags-read").addClass("hide")
  }

  return InlineFormNodeTag
})()

$.fn.initInlineFormNodeTag = function (options) {
  options = options || {}
  return this.each(function () {
    options.el = $(this)
    return new InlineFormNodeTag(options)
  })
}

$(function () {
  $(document).on("modal:contentUpdated", function () {
    return $(".js-inline-form-node-tags").initInlineFormNodeTag()
  })
  return $(".js-inline-form-node-tags").initInlineFormNodeTag()
})
