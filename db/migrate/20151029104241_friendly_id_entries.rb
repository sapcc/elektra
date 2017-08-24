class FriendlyIdEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :friendly_id_entries do |t|
      t.string :class_name
      t.string :scope
      t.string :name
      t.string :slug
      t.string :key

      t.timestamps null: false
    end
    
    add_index :friendly_id_entries, :class_name
    add_index :friendly_id_entries, :scope
    add_index :friendly_id_entries, :key
    add_index :friendly_id_entries, :slug
    add_index :friendly_id_entries, [:class_name, :scope, :key]
    add_index :friendly_id_entries, [:class_name, :key]
  end
end
