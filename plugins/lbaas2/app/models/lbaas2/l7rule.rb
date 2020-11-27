# frozen_string_literal: true

module Lbaas2
  class L7rule < Core::ServiceLayer::Model

    validates :key, presence: {
      message: 'Please set a key name for Cookie and Header types'
    }, if: :type_header_cookie?
    validates :key, format: {
      with: /\A[a-zA-Z!#$%&'*+-.^_`|~]+\z/,
      message: 'Invalid characters in value. See RFCs 2616, 2965, 6265, 7230.'
    }, if: :type_header_cookie?
    validates :value, presence: true, format: {
      with: %r{\A[a-zA-Z\d!#$%&'()*+-\./:<=>?@\[\]^_`{|}~]+\z},
      message: 'Invalid characters in value. See RFCs 2616, 2965, 6265.'
    }
    validates :type, presence: true
    validates :compare_type, presence: true

    def type_header_cookie?
      return type == 'HEADER' || type == 'COOKIE'
    end

    def save
      if valid?
        persist!
      else
        false
      end
    end

    def update()
      if valid?
        update!()
      else
        false
      end
    end


    def destroy()
      destroy!()
    end

    def attributes_for_create
      {
        'type'                => read('type'),
        'admin_state_up'      => read('admin_state_up'),
        'compare_type'        => read('compare_type'),
        'invert'              => read('invert'),
        'value'               => read('value'),
        'key'                 => read('key'),
        'tags'                => read('tags'),
        'project_id'          => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'type'                => read('type'),
        'compare_type'        => read('compare_type'),
        'invert'              => read('invert'),
        'value'               => read('value'),
        'key'                 => read('key'),
        'tags'                => read('tags')
      }
    end

  private

    def destroy!()
      service.delete_l7rule(attributes['l7policy_id'], id)
    rescue ::Elektron::Errors::ApiResponse => e
      rescue_eletron_errors(e)
      false
    end

    def persist!()
      newL7rule = service.create_l7rule(attributes['l7policy_id'], attributes_for_create)
      # update self with the new rule
      self.attributes = newL7rule
      true
    rescue ::Elektron::Errors::ApiResponse => e
      rescue_eletron_errors(e)
      false
    end

    def update!()
      newL7rule = service.update_l7rule(attributes['l7policy_id'], id, attributes_for_update)
      self.attributes = newL7rule
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