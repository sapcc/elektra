threads_count = Integer(ENV['MAX_THREADS'] || 10)
threads threads_count, threads_count

environment ENV['RAILS_ENV'] || 'production'
port ENV['PORT'] || 80
