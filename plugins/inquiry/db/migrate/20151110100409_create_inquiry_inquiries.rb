class CreateInquiryInquiries < ActiveRecord::Migration
  def change
    create_table :inquiry_inquiries do |t|
      t.string :kind
      t.string :requester_id
      t.text :description
      t.json :payload
      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
