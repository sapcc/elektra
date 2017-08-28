class AddTagsToInquiryInquiries < ActiveRecord::Migration[4.2]
  def change
    add_column :inquiry_inquiries, :tags, :json
  end
end
