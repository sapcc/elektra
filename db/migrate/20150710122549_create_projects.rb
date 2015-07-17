class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :key
      t.string :name
      t.string :slug
      t.belongs_to :domain, index:true

      t.timestamps null: false
    end
  end
end
