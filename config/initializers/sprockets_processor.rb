# The main purpose of this code is to create a copy of '.bundle.js' files without the digest (hash) in the file name. 
# This allows to access these assets with a consistent name without having the hash in the file name.
module NonDigestAssets
  def self.call(input)
    filename = input[:filename]
    # check if the file is a .bundle.js file
    if filename.end_with?('.bundle.js')
      # copy the file to the public/assets folder
      # without the digest in the file name
      path = File.join(Rails.public_path, 'assets', File.basename(filename))
      FileUtils.cp(filename, path)
    end
    nil
  end
end

Sprockets.register_postprocessor 'application/javascript', NonDigestAssets
