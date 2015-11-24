class CreateInquiryProcessors < ActiveRecord::Migration
  def change
    create_table :inquiry_processors do |t|
      t.string :uid

      t.timestamps null: false
    end
  end
end
