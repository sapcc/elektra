class ChangeColumnResourceManagementResourcesDomainId < ActiveRecord::Migration
  def change
    change_column_null :resource_management_resources, :domain_id, false
  end
end
