# frozen_string_literal: true

module Lbaas2
  class L7policy < Core::ServiceLayer::Model
    validates :name, presence: true
    validates :action, presence: true

    def save
      if valid?
        persist!
      else
        false
      end
    end

    def attributes_for_create
      {
        'name'                => read('name'),
        'description'         => read('description'),
        'position'            => read('position'),
        'action'              => read('action'),
        'redirect_url'        => read('redirect_url'),        
        'redirect_prefix'     => read('redirect_prefix'),
        'redirect_http_code'  => read('redirect_http_code'),
        'redirect_pool_id'    => read('redirect_pool_id'),
        'tags'                => read('tags'),
        'listener_id'         => read('listener_id'),
        'project_id'          => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    private

    def persist!()
      newL7policy = service.create_l7policy(attributes_for_create)
      # update self with the new policy
      self.update_attributes(newL7policy)
      true
    rescue ::Elektron::Errors::ApiResponse => e
      rescue_eletron_errors(e)
      false
    end

    def rescue_eletron_errors(e)
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
    end

  end
end