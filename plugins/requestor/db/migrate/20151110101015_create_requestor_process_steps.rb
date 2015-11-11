class CreateRequestorProcessSteps < ActiveRecord::Migration
  def change
    create_table :requestor_process_steps do |t|
      t.string :from_state
      t.string :to_state
      t.string :event
      t.string :processor_id
      t.text :description
      t.integer :inquiry_id

      t.timestamps null: false
    end
  end
end
