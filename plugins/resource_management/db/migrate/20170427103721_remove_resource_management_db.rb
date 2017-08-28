class RemoveResourceManagementDb < ActiveRecord::Migration[4.2]
  def up
    drop_table :resource_management_resources
    drop_table :resource_management_capacities
  end
end
