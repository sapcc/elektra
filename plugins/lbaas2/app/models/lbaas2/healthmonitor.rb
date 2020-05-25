module Lbaas2
  class Healthmonitor < Core::ServiceLayer::Model

    validates :name, presence: true
    validates :type, presence: true
    validates :delay, presence: true, numericality: { greater_than: 0 }
    validates :max_retries, presence: true, inclusion: {
      in: '1'..'10',
      message: 'You can have between 1 and 10 retries'
    }
    validate :timeoutvalue

    def timeoutvalue
      new_timeout = read('timeout')
      if new_timeout.to_i <= 0
        errors.add(:timeout, 'Please enter a timeout greater 0')
      elsif new_timeout.to_i >= delay.to_i
        errors.add(:timeout, 'Please enter a timeout less than the "Delays" value')
      end
    end

    def attributes_for_create
      {
        'name' => read('name'),
        'type' => read('type'),
        'max_retries' => read('max_retries'),
        'timeout' => read('timeout'),
        'delay' => read('delay'),
        'http_method' => read('http_method'),
        'expected_codes' => read('expected_codes'),
        'url_path' => read('url_path'),
        'pool_id' => read('pool_id'),
        'project_id' => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    private

    def persist!()
      newHealthMonitor= service.create_healthmonitor(attributes_for_create)
      # update self with the new health monitor
      self.update_attributes(newHealthMonitor)
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
