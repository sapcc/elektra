module FlashHelper
  def flash_entry(_key, _value)
    key = _key.to_s.downcase
    flash_types = %w[success info notice warning danger alert error]
    auto_dismissible_types = %w[success info notice]

    html_safe = false
    if key.end_with?("htmlsafe")
      html_safe = true
      key = key.sub(/_htmlsafe$/, "")
    end

    keep_flash = false
    if key.start_with?("keep_")
      keep_flash = true
      key = key.sub(/^keep_/, "")
    end

    auto_dismissible =
      keep_flash == false && auto_dismissible_types.include?(key) ? true : false

    if flash_types.include? key
      {
        partial: "application/flash_dismissible",
        locals: {
          key: key,
          value: _value,
          auto_dismissible: auto_dismissible,
          html_safe: html_safe,
        },
      }
    else
      {
        partial: "application/flash_default",
        locals: {
          key: key.sub(/^default_/, ""),
          value: _value,
        },
      }
    end
  end
end
