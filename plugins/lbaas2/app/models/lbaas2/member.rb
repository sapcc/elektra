module Lbaas2
  class Member < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :address, presence: true
    validates :weight, presence: true, inclusion: {
      in: '1'..'256',
      message: 'Choose a weight between 1 and 256'
    }
    validates :protocol_port, presence: true, inclusion: {
      in: '1'..'65535',
      message: 'Choose a port between 1 and 65535'
    }

    def attributes_for_create
      {
        'name'            => read('name'),
        'address'       => read('address'),        
        'protocol_port' => read('protocol_port'),
        'weight'         => read('weight'),
        'project_id'    => read('project_id'),        
        'subnet_id'     => read('subnet_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def save
      if valid?
        persist!
      else
        false
      end
    end

    private

    def persist!()
      newMember = service.create_member(attributes['pool_id'], attributes_for_create)
      # update self with the new member
      self.update_attributes(newMember)
      true
    rescue ::Elektron::Errors::ApiResponse => e
      apiErrorCount = 0
      apiKey = "api_error_" + apiErrorCount.to_s
      e.messages.each do |m| 
        # scan string
        keywords = {}
        m.scan(/[\w']+/) do |w|
          if attributes_for_create.key? (w)
            keywords[w.to_s] = m
          end
        end
        if keywords.keys.count == 1
          # 1 key was found
          keywords.keys.each do |key|
            errors.add(key.to_s, keywords[key])                     
          end   
        else
          # no key or more than 1 key was found in the sentence
          errors.add(apiKey.to_s, m) unless m.blank?
          apiErrorCount += 1
        end
      end
      false
    end

  end
end
