# frozen_string_literal: true

module EmailService
  # barbican container
  class Template < ::Core::ServiceLayer::Model

    strip_attributes
    validates_presence_of :name, :subject, :htmlbody, :textbody

    def attributes_for_create
      {
        'name'          => read('name'),
        'subject'       => read('subject'),
        'htmlbody'      => read('htmlbody'),
        'textbody'      => read('textbody')
      }.delete_if { |_k, v| v.blank? }
    end

    def id
      super || URI(template_ref).path.split('/').last
    rescue
      nil
    end

    def display_name
      name.blank? ? 'Empty name' : name
    end
    
    alias uuid id
  end
end
