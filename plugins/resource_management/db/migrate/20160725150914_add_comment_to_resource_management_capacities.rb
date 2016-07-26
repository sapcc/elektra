class AddCommentToResourceManagementCapacities < ActiveRecord::Migration
  def change
    add_column :resource_management_capacities, :comment, :string
  end
end
