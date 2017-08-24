class AddProjectDomainCallbackToInquiries < ActiveRecord::Migration[4.2]
  def change
    add_column :inquiry_inquiries, :project_id, :string
    add_column :inquiry_inquiries, :domain_id, :string
    add_column :inquiry_inquiries, :callbacks, :json
  end
end
