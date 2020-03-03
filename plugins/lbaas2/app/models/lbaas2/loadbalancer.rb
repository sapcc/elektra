# frozen_string_literal: true

module Lbaas2
  # represents openstack lb
  class Loadbalancer < Core::ServiceLayer::Model
    validates :vip_subnet_id, presence: true, if: -> { id.nil? }
    validates :name, presence: true

    # def delete?
    #   listeners.blank? && pools.blank?
    # end

    def save
      if valid?
        persist!
      else
        false
      end
    end

    def attributes_for_create
      {
        'name'            => read('name'),
        'description'     => read('description'),
        'vip_subnet_id'   => read('vip_subnet_id'),        
        'vip_address'     => read('vip_address'),        
        'project_id'      => read('project_id'),
        'tags'            => read('tags')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'name'            => read('name'),
        'description'     => read('description'),
        'admin_state_up'  => read('admin_state_up'),
        'tags'            => read('tags')
      }.delete_if { |k, v| v.blank? and !%w[name description].include?(k) }
    end

    private

    def persist!()
      service.create_loadbalancer(attributes_for_create)
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
