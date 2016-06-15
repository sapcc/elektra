class AddNameToProcessor < ActiveRecord::Migration
  def change
    add_column :inquiry_processors, :name, :string
  end
end
