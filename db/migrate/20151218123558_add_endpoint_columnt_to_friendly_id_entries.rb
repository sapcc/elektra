class AddEndpointColumntToFriendlyIdEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :friendly_id_entries, :endpoint, :string
  end
end
