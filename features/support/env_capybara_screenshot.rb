require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'
require 'mime-types'
require 'elektron'

Capybara.save_path = 'features/screenshots'

module Screenshots
  class Uploader
    def initialize
      @client = Elektron.client(
        {
          url: ENV['SCREEN_SHOT_UPLOAD_URL'],
          user_name: ENV['SCREEN_SHOT_UPLOAD_USER'],
          user_domain_name: ENV['SCREEN_SHOT_UPLOAD_DOMAIN'],
          password: ENV['SCREEN_SHOT_UPLOAD_PASSWORD'],
          scope_project_domain_name: ENV['SCREEN_SHOT_UPLOAD_DOMAIN'],
          scope_project_name: ENV['SCREEN_SHOT_UPLOAD_PROJECT']
        },
        region: 'staging', interface: 'public', debug: false
      )
      @swift = @client.service('object-store')
    end

    def upload(path)
      basename     = File.basename(path)
      extension    = File.extname(path)[1..-1]
      type         = MIME::Types.type_for(extension)
      content      = File.read(path)

      headers = {
        'X-Delete-After' => (60 * 60 * 24 * 7).to_s,
        'Content-Disposition' => "inline;filename=#{basename}",
        'Content-Type' => type.to_s
      }

      @swift.put(
        "elektra_capybara_screenshots/#{basename}", headers: headers
      ) { content }
    end
  end
end

# empty screenshot dir
FileUtils.rm_rf(Dir.glob('features/screenshots/*'))
at_exit do
  # do the work in a separate thread, to avoid stomping on $!,
  # since other libraries depend on it directly.
  unless Capybara.run_server
    Thread.new do
      unless Dir['features/screenshots/*'].empty?
        puts ''
        puts ''
        puts '         \''
        puts '    \'    )'
        puts '     ) ('
        puts '    ( .\')  __/\\'
        puts '      (.  /o/\` \\'
        puts '       __/o/\`   \\'
        puts 'FAIL  / /o/\`    /'
        puts '^^^^^^^^^^^^^^^^^^^^'
        puts ''
        puts 'Some tests failed. But do not despair. Check these URLs:'

        uploader = Screenshots::Uploader.new
        Dir['features/screenshots/*'].each do |file|
          # puts Screenshots::upload(File.expand_path(file))
          uploader.upload(File.expand_path(file))
        end

        puts ''
        puts ''
      end
    end.join
  end
end
