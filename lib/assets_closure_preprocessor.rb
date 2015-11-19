# Surrounds all js files inside a plugin with a closure.
class AssetsClosurePreprocessor < Sprockets::Processor
  def evaluate(context, locals)

    # is current js file from a plugin 
    if context.root_path.include?("/plugins/")
      # get the plugin name
      plugin_name = context.root_path[context.root_path.index("/plugins/")+9..context.root_path.index("/app/assets")-1]
      
      # surround data with (function(){ ... }).
      # first, define variable current_plugin unless already defined.
      # second, define a closure.
      # third, call the closure with current_plugin as parameter.
      closure = "var #{plugin_name} = #{plugin_name} || {};\n"+ 
        "(function(){\n"+
          "var #{plugin_name} = this;\n"+
          "#{data}\n"+
        "}).call(#{plugin_name});\n"
            
      data.replace closure
    end
    data
  end
end