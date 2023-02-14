class UserProfile < ApplicationRecord
  has_many :domain_profiles
  # NOTE: since we create a user profile for every user ID and a user has a different user ID in every domain,
  # there will only ever be one domain profile per user profile. And a natural user will have one user profile
  # per domain. Might be worth thinking about changing at some point so we have one user profile per natural user
  # and the domain profiles contain the user id per domain or something like that...

  scope :search_by_name,
        ->(name) {
          where("full_name ILIKE ? or name ILIKE ?", "%#{name}%", "%#{name}%")
        }

  def self.tou_accepted?(user_id, domain_id, version)
    p = UserProfile.tou(user_id, domain_id, version)
    p.present?
  end

  def self.tou(user_id, domain_id, version)
    UserProfile
      .find_by(uid: user_id)
      .domain_profiles
      .find_by(
        tou_version: version, # check if any domain profile exists where the user has accepted the given tou version
      )
  rescue StandardError
    false
  end

  # this methods tries to find cached user ba name. It expects a block which
  # returns the user from API.
  def self.find_by_name_or_create_or_update(user_name)
    user_profile = UserProfile.search_by_name(user_name).first

    if user_profile.nil?
      user = yield
      return nil unless user
      return(
        UserProfile.create_with(
          name: user.name,
          email: user.email,
          full_name: user.full_name,
        ).find_or_create_by(uid: user.id)
      )
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
