# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }

# You can also remove all the silencers if you're trying to debug a problem that might stem from framework code.
Rails.backtrace_cleaner.remove_silencers!

# Silence what Rails silenced, UNLESS it looks like
# it's from plugin engines
plugin_root_regex = Regexp.escape ("plugins" + File::SEPARATOR)
Rails.backtrace_cleaner.add_silencer do |line|
  (line !~ Rails::BacktraceCleaner::APP_DIRS_PATTERN) &&
    (line !~ /^#{plugin_root_regex}/)
end
