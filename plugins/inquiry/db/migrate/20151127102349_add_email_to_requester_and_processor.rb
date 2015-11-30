class AddEmailToRequesterAndProcessor < ActiveRecord::Migration
  def change
    remove_column :inquiry_process_steps, :processor_id
    add_column :inquiry_process_steps, :processor_id, :integer, index: true
    add_column :inquiry_inquiries, :requester_email, :string
    add_column :inquiry_inquiries, :requester_full_name, :string
    add_column :inquiry_processors, :email, :string
    add_column :inquiry_processors, :full_name, :string
  end
end
