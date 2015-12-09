module Inquiry
  class Processor < ActiveRecord::Base

    has_and_belongs_to_many :inquiries

    def self.from_users users
      res = []
      users.each do |user|
        p = Processor.find_by(uid: user.id)
        if p
          if p.email != user.email || p.full_name != user.full_name
            p.email = user.email
            p.full_name = user.full_name
            p.save
          end
        else
          p = Processor.new(uid: user.id, email: user.email, full_name: user.full_name) unless p
        end
        res << p
      end
      return res
    end

  end
end
