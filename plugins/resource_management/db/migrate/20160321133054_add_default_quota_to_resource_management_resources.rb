class AddDefaultQuotaToResourceManagementResources < ActiveRecord::Migration
  def change
    add_column :resource_management_resources, :default_quota, :integer, limit:8
  end
end
