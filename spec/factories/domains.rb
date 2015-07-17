FactoryGirl.define do
  factory :domain do
    key "default"
    name {key}
    #slug "default"
  end
end
