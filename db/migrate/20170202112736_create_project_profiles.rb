class CreateProjectProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :project_profiles do |t|
      t.string :project_id
      t.text :wizard_payload

      t.timestamps null: false
    end
  end
end
