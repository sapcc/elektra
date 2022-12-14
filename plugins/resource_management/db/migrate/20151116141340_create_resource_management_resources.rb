class CreateResourceManagementResources < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_management_resources do |t|
      t.string :cluster_id
      t.string :domain_id
      t.string :project_id
      t.string :service
      t.string :name
      t.integer :current_quota, limit: 8
      t.integer :approved_quota, limit: 8
      t.integer :usage, limit: 8

      t.timestamps null: false
    end
    add_index :resource_management_resources,
              %i[domain_id project_id service name],
              name: "resource_management_resources_master_index",
              using: :btree
  end
end
