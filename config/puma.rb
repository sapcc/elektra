threads_count = Integer(ENV['MAX_THREADS'] || 10)
threads 1, threads_count

environment ENV['RAILS_ENV'] || 'production'
port ENV['PORT'] || 80

require 'puma/app/status'
activate_control_app 'tcp://127.0.0.1:7353', { no_token: 'true' }

plugin :tmp_restart