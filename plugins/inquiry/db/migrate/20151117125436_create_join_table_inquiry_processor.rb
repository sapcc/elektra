class CreateJoinTableInquiryProcessor < ActiveRecord::Migration[4.2]
  def change
    create_join_table(
      :inquiries,
      :processors,
      { table_name: "inquiry_inquiries_processors" },
    ) do |t|
      t.index %i[inquiry_id processor_id], name: "index_inquiry_processor"
      t.index %i[processor_id inquiry_id], name: "index_processor_inquiry"
    end
  end
end
