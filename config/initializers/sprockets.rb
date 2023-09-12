require_relative "../../lib/assets_closure_preprocessor.rb"
# register closure preprocessor for js files. It surrounds a js code with a closure.
Sprockets.register_postprocessor(
  "application/javascript",
  AssetsClosurePreprocessor.new,
)
