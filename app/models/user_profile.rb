class UserProfile < ApplicationRecord
  has_many :domain_profiles

  scope :search_by_name, ->(name) {
    where('full_name ILIKE ? or name ILIKE ?', "%#{name}%", "%#{name}%")
  }

  def self.tou_accepted?(user_id, domain_id, version)
    p = UserProfile.tou(user_id, domain_id, version)
    p.present?
  end

  def self.tou(user_id, domain_id, version)
    UserProfile.find_by(uid: user_id).domain_profiles.find_by(
      domain_id: domain_id, tou_version: version
    )
  rescue
    false
  end

  # this methods tries to find cached user ba name. It expects a block which
  # returns the user from api.
  def self.find_by_name_or_create_or_update(user_name)
    user_profile = UserProfile.search_by_name(user_name).first

    if user_profile.nil?
      user = yield
      return nil unless user
      return UserProfile.create_with(
        name: user.name, email: user.email, full_name: user.full_name
      ).find_or_create_by(uid: user.id)
    end

    if user_profile.full_name.blank? || user_profile.email.blank?
      user = yield
      return user_profile unless user
      user_profile.full_name = user.description
      user_profile.email = user.email
      user_profile.save
    end
    user_profile
  end
end
