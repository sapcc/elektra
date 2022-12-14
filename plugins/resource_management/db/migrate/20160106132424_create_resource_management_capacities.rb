class CreateResourceManagementCapacities < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_management_capacities do |t|
      t.string :cluster_id
      t.string :service
      t.string :resource
      t.integer :value, limit: 8

      t.timestamps null: false
    end
    add_index :resource_management_capacities,
              %i[service resource],
              name: "resource_management_capacities_master_index",
              using: :btree
  end
end
