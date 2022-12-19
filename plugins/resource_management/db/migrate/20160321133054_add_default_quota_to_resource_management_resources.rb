class AddDefaultQuotaToResourceManagementResources < ActiveRecord::Migration[
  4.2
]
  def change
    add_column :resource_management_resources,
               :default_quota,
               :integer,
               limit: 8
  end
end
