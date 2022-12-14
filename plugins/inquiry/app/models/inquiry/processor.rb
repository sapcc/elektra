module Inquiry
  class Processor < ApplicationRecord
    has_and_belongs_to_many :inquiries

    def self.from_users(users)
      res = []
      users.each do |user|
        processor = Processor.find_or_create_by(uid: user.id)
        begin
          if user.is_a? CurrentUserWrapper::CurrentUserWrapper
            # for current_user
            if processor.email != user.email or processor.name != user.name or
                 processor.full_name != user.full_name
              processor.update(
                {
                  email: user.email,
                  name: user.name,
                  full_name: user.full_name,
                },
              )
            end
          elsif user.respond_to?(:description)
            if processor.email != user.email or processor.name != user.name or
                 processor.full_name != user.description
              processor.update(
                {
                  email: user.email,
                  name: user.name,
                  full_name: user.description,
                },
              )
            end
          end
        rescue => e
          Rails.logger.warn "Can't update processor attributes for user.id: #{user.id} " +
                              e.message
        end
        res << processor
      end
      return res
    end
  end
end
