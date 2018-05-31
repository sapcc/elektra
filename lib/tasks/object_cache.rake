namespace :object_cache do
  desc "Clear old entries (more than 4 weeks old)"
  task :cleanup => :environment do
    sql = "DELETE FROM object_cache WHERE (updated_at < '#{Date.today - 4.weeks}')"
    ActiveRecord::Base.connection.execute(sql)
  end
end
