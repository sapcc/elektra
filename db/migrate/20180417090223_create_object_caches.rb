class CreateObjectCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :object_cache, id: false do |t|
      t.string :id, primary_key: true
      t.string :name
      t.string :project_id
      t.string :domain_id
      t.string :cached_object_type
      t.json   :payload
      t.timestamps
    end

    add_index :object_cache, :id
    add_index :object_cache, :name
    add_index :object_cache, :project_id
    add_index :object_cache, :cached_object_type
  end
end
