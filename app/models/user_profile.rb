class UserProfile < ActiveRecord::Base
  has_many :domain_profiles
end
