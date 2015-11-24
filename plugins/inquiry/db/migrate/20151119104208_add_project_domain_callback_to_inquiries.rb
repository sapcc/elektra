class AddProjectDomainCallbackToInquiries < ActiveRecord::Migration
  def change
    add_column :inquiry_inquiries, :project_id, :string
    add_column :inquiry_inquiries, :domain_id, :string
    add_column :inquiry_inquiries, :callbacks, :json
  end
end
