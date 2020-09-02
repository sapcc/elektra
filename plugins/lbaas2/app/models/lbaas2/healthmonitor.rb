module Lbaas2
  class Healthmonitor < Core::ServiceLayer::Model

    validates :name, presence: true
    validates :type, presence: true
    validates :delay, presence: true, numericality: { greater_than: 0 }
    validates :max_retries, presence: true, inclusion: {
      in: 1..10,
      message: 'You can have between 1 and 10 retries'
    }
    validate :timeout_check

    def timeout_check
      new_timeout = read('timeout')
      new_delay = read('delay')
      if new_timeout.to_i <= 0
        errors.add(:timeout, 'Please enter a timeout greater 0')
      elsif new_timeout.to_i >= new_delay.to_i
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
        'tags' => read('tags'),
        'pool_id' => read('pool_id'),
        'project_id' => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name' => read('name'),
        'max_retries' => read('max_retries'),
        'timeout' => read('timeout_value'),
        'delay' => read('delay'),        
        'http_method' => read('http_method'),
        'expected_codes' => read('expected_codes'),
        'url_path' => read('url_path'),
        'tags' => read('tags'),
        'admin_state_up' => read('admin_state_up')
      }
    end

  end
end
