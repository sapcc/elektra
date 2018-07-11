require 'colorize'
require 'capybara-screenshot'
require 'capybara-screenshot/cucumber'
require 'mime-types'
require 'elektron'

Capybara.save_path = 'features/screenshots'

module Screenshots
  class Uploader
    def self.can_upload?
      %w[SCREEN_SHOT_UPLOAD_URL SCREEN_SHOT_UPLOAD_USER
         SCREEN_SHOT_UPLOAD_DOMAIN SCREEN_SHOT_UPLOAD_PASSWORD
         SCREEN_SHOT_UPLOAD_DOMAIN SCREEN_SHOT_UPLOAD_PROJECT].collect do |v|
           ENV[v] && !ENV[v].empty? && true
      end.all?
    end

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
        region: ENV['MONSOON_DASHBOARD_REGION'] || 'qa-de-1', interface: 'public', debug: false
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

      # return the public url
      "#{@swift.endpoint_url}/elektra_capybara_screenshots/#{basename}"
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

        if Screenshots::Uploader.can_upload?
          puts 'Some tests failed. But do not despair. Check these URLs:'
          uploader = Screenshots::Uploader.new
          Dir['features/screenshots/*'].each do |file|
            # puts Screenshots::upload(File.expand_path(file))
            puts uploader.upload(File.expand_path(file)).colorize(:green)
          end
        end

        puts ''
        puts ''
      end
    end.join
  end
end
