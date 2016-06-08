class RenameFirstnameDeleteLastnameInUserProfiles < ActiveRecord::Migration
  def change
    rename_column :user_profiles, :first_name, :full_name
    remove_column :user_profiles, :last_name
  end
end

