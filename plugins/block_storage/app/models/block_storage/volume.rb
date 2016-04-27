module BlockStorage
  class Volume < Core::ServiceLayer::Model
    validates :name, :description, :size, presence: true
    attr_accessor :assigned_server

    def in_transition? target_state
      Rails.logger.info { "Checking state transition for volume #{self.name} : target state: #{target_state} - actual state: #{self.status}" }
      if target_state == self.status
        return false
      else
        return true
      end
    end

  end
end