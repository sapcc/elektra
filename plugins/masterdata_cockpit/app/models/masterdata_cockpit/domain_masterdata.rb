module MasterdataCockpit
  class DomainMasterdata < Core::ServiceLayer::Model
    # the following attributes ar known
    #"domain_id":"ABCD1234",
    #"domain_name":"MyDomain0815",
    #"description":"MyDomain is about providing important things",
    #"responsible_primary_contact_id": "D000000",
    #"responsible_primary_contact_email": "myDL@sap.com",
    #"responsible_controller_id": "D000000",
    #"responsible_controller_email": "myDL@sap.com",
    #"cost_object": {
    #    "type": "IO",
    #    "name": "myIO",
    #    "projects_can_inherit": false
    #}

    validates_presence_of :cost_object_type, :cost_object_name

    validates_presence_of :responsible_controller_id, unless: lambda { self.responsible_controller_email.blank? }, message: "can't be blank if controller email is defined"
    validates_presence_of :responsible_controller_email, unless: lambda { self.responsible_controller_id.blank? }, message: "can't be blank if controller is defined"
    
    validates_presence_of :responsible_primary_contact_id, unless: lambda { self.responsible_primary_contact_email.blank? }, message: "can't be blank primary contact email is defined"
    validates_presence_of :responsible_primary_contact_email, unless: lambda { self.responsible_primary_contact_id.blank? }, message: "can't be blank if primary contact is defined"


    validates :responsible_controller_email,
      format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "please use a valid email address" },
      allow_nil: true,
      allow_blank: true

    validates :responsible_controller_id,
      format: { with: /\A[DCIdci]\d*\z/, message: "please use a C/D/I user id"},
      allow_nil: true,
      allow_blank: true

    validate :validate_inheritance

    def cost_object_name
      if read('cost_object_name')
        read('cost_object_name')
      elsif cost_object
        cost_object['name']
      else
        nil
      end
    end

    def cost_object_type
      if read('cost_object_type')
        read('cost_object_type')
      elsif cost_object
        cost_object['type']
      else
        nil
      end
    end

    def cost_object_projects_can_inherit
      if read('cost_object_projects_can_inherit')
        read('cost_object_projects_can_inherit') == "true"
      elsif cost_object
        cost_object['projects_can_inherit']
      else
        false
      end
    end

    def attributes_for_create
      params = {
        'domain_id'                         => read('domain_id'),
        'domain_name'                       => read('domain_name'),
        'description'                       => read('description'),
        'responsible_controller_id'         => read('responsible_controller_id'),
        'responsible_controller_email'      => read('responsible_controller_email'),
        'responsible_primary_contact_id'    => read('responsible_primary_contact_id'),
        'responsible_primary_contact_email' => read('responsible_primary_contact_email'),
      }.delete_if { |_k, v| v.blank? }

      if read('projects_can_inherit') == "true"
        params['cost_object'] = {'cost_object_projects_can_inherit' => true}
      else
        params['cost_object'] = {
          'name' => read('cost_object_name'),
          'type' => read('cost_object_type'),
          'projects_can_inherit' => read('cost_object_projects_can_inherit') == "true"
        }
      end

      params
    end

    def validate_inheritance
      return unless cost_object_projects_can_inherit

      # respect the configured domain blacklist (this blacklist includes
      # domains with a diverse set of customers and project cost objects, where
      # we definitely don't want cost objects to be inherited to projects)
      @@blacklisted_domains ||= ENV.fetch('DOMAIN_MASTERDATA_INHERITANCE_BLACKLIST', '').split(',')
      domain_name = read('domain_name')
      if @@blacklisted_domains.include?(domain_name)
        errors.add(:cost_object_projects_can_inherit, "is not allowed for domain #{domain_name}")
      end
    end

  end
end
