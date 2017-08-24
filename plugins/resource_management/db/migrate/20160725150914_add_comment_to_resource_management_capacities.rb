class AddCommentToResourceManagementCapacities < ActiveRecord::Migration[4.2]
  def change
    add_column :resource_management_capacities, :comment, :string
  end
end
