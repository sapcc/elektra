class UserProfile < ActiveRecord::Base
  has_many :domain_profiles

  scope :search_by_name, -> (name) { where('full_name like ? or name like ?', "%#{name}%",  "%#{name}%") }

end
