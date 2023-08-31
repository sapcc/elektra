# register closure preprocessor for js files. It surrounds a js code with a closure.
require_relative "../../lib/assets_closure_preprocessor"

Sprockets.register_postprocessor(
  "application/javascript",
  AssetsClosurePreprocessor.new,
)
