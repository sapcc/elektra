# register closure preprocessor for js files. It surrounds a js code with a closure.
Rails.application.assets.register_preprocessor('application/javascript', AssetsClosurePreprocessor)