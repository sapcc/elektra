class ChangeColumnResourceManagementResourcesDomainId < ActiveRecord::Migration[
  4.2
]
  def change
    change_column_null :resource_management_resources, :domain_id, false
  end
end
