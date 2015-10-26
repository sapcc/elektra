class CreateFriendlyIdEntries < ActiveRecord::Migration
  def up
    # remove obsolete tables used for friendly_ids
    drop_table :domains if ActiveRecord::Base.connection.table_exists? 'domains' 
    drop_table :projects if ActiveRecord::Base.connection.table_exists? 'projects' 
 
    # create a new table which contains all friendly_id entries
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
  
  def down
    drop_table :friendly_id_entries
  end
end
