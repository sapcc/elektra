# Surrounds all js files inside a plugin with a closure.
class AssetsClosurePreprocessor
  def call(input)
    match = %r{/plugins/(.+)/app/javascript}.match(input[:load_path])
    data = input[:data]

    if match
      # get the plugin name
      plugin_name = match[1]
      data.replace "window.#{plugin_name} = window.#{plugin_name} || {};\n\n#{data}"
      data.replace "(function(){\n  #{data}\n}).call(this);\n"
    end

    return { data: data }
  end
end
