class AddSearchLabelToObjectCache < ActiveRecord::Migration[5.1]
  def change
    add_column :object_cache, :search_label, :string
    add_index :object_cache, :search_label
  end
end
