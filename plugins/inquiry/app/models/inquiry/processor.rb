module Inquiry
  class Processor < ActiveRecord::Base

    has_and_belongs_to_many :inquiries

    def self.from_users users
      res = []
      users.each do |user|
        p = Processor.find_by(uid: user.id)
        p = Processor.new(uid: user.id, email: user.email, full_name: user.full_name) unless p
        res << p
      end
      return res
    end

  end
end
