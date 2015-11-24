class CreateInquiryProcessSteps < ActiveRecord::Migration
  def change
    create_table :inquiry_process_steps do |t|
      t.string :from_state
      t.string :to_state
      t.string :event
      t.string :processor_id
      t.text :description
      t.belongs_to :inquiry, index: true

      t.timestamps null: false
    end
  end
end
