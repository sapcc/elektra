class AddNameToProcessor < ActiveRecord::Migration[4.2]
  def change
    add_column :inquiry_processors, :name, :string
  end
end
