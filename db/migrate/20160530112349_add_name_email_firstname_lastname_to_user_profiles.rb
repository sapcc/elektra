class AddNameEmailFirstnameLastnameToUserProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :user_profiles, :name, :string
    add_column :user_profiles, :email, :string
    add_column :user_profiles, :first_name, :string
    add_column :user_profiles, :last_name, :string
    add_index :user_profiles, :uid
    add_index :user_profiles, :name
  end
end