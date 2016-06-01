class CreateDomainProfiles < ActiveRecord::Migration
  def change
    create_table :domain_profiles do |t|
      t.string :domain_id
      t.references :user_profile, index: true, foreign_key: true
      t.string :tou_version

      t.timestamps null: false
    end
  end
end
