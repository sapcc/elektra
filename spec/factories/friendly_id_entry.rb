FactoryBot.define do
  factory :friendly_id_entry, class: "FriendlyIdEntry" do
    class_name { "ClassName" }
    scope nil
    name { "MyString" }
    key { "MyString" }
  end
end
