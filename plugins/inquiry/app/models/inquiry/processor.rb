module Inquiry
  class Processor < ActiveRecord::Base

    has_and_belongs_to_many :inquiries

    def self.from_users users

      res = []
      users.each do |user|
        processor = Processor.find_or_create_by(uid: user.id)
        processor.update_attributes({ email: user.email, full_name: user.full_name })
        res << processor
      end
      return res
    end

  end
end
