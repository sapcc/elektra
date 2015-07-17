class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :key
      t.string :name
      t.string :slug

      t.timestamps null: false
    end
  end
end
