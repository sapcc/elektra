class SearchNodesService
  def self.search_query(search_text)
    return "" if search_text.blank?

    if search_text.include?("=")
      # advance search
      key_value = search_text.split("=")
      if key_value.length == 2
        key = key_value[0].delete(" ")
        value = key_value[1].strip
        return "" if key.blank? || value.blank?
        self.advance_query(key, value)
      else
        return ""
      end
    else
      # search
      self.query(search_text.strip)
    end
  end

  # string
  def self.query(value)
    "name ^ '*#{value}*' OR @hostname ^ '*#{value}*' OR @identity ^ '*#{value}*'"
  end

  # key=value
  def self.advance_query(key, value)
    "#{key} ^ '*#{value}*' OR @#{key} ^ '*#{value}*'"
  end
end
