namespace :friendly_ids do
  desc "Reset friendly id entries (delete all)"
  task reset: :environment do
    FriendlyIdEntry.delete_all
  end
end
