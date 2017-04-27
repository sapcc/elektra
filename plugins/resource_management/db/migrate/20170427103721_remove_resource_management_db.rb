class RemoveResourceManagementDb < ActiveRecord::Migration
  def up
    drop_table :resource_management_resources
    drop_table :resource_management_capacities
  end
end
