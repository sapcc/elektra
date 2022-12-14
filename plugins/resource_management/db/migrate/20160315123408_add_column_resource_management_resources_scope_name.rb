class AddColumnResourceManagementResourcesScopeName < ActiveRecord::Migration[
  4.2
]
  def change
    add_column :resource_management_resources,
               :scope_name,
               :string,
               default: nil
  end
end
