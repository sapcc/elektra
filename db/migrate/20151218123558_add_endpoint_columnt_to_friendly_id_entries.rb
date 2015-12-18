class AddEndpointColumntToFriendlyIdEntries < ActiveRecord::Migration
  def change
    add_column :friendly_id_entries, :endpoint, :string
  end
end
