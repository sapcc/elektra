class AddTagsToInquiryInquiries < ActiveRecord::Migration
  def change
    add_column :inquiry_inquiries, :tags, :json
  end
end
