# The main purpose of this code is to create a copy of '_widget.js' files without the digest (hash) in the file name.
# This allows to access these assets with a consistent name without having the hash in the file name.
module NonDigestAssets
  def self.call(input)
    filename = input[:filename]
    # check if the file is a _widget.js file
    # copy the file to the public/assets folder
    if filename.end_with?('_widget.js')
      target_dir = File.join(Rails.public_path, 'assets')
      target_path = File.join(target_dir, File.basename(filename))
      # Ensure the target directory exists
      FileUtils.mkdir_p(target_dir)
      # Copy the file
      FileUtils.cp(filename, target_path)
    end
    nil
  end
end

Sprockets.register_postprocessor 'application/javascript', NonDigestAssets
