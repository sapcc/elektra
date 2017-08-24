class CreateUserProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :user_profiles do |t|
      t.string :uid

      t.timestamps null: false
    end
  end
end
