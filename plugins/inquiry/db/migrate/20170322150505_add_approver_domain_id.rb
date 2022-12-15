class AddApproverDomainId < ActiveRecord::Migration[4.2]
  def change
    add_column :inquiry_inquiries, :approver_domain_id, :string, index: true
    ::Inquiry::Inquiry.all.each do |i|
      i.update_attribute("approver_domain_id", i.domain_id)
      #byebug
    end
  end
end
