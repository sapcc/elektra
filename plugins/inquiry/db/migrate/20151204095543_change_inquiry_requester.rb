class ChangeInquiryRequester < ActiveRecord::Migration[4.2]
  def change
    remove_column :inquiry_inquiries, :requester_id
    remove_column :inquiry_inquiries, :requester_email
    remove_column :inquiry_inquiries, :requester_full_name
    add_column :inquiry_inquiries, :requester_id, :integer, index: true
  end
end
