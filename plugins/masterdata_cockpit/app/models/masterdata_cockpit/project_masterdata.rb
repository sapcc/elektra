module MasterdataCockpit
  class ProjectMasterdata < Core::ServiceLayer::Model
    # https://billing.staging.cloud.sap:23000/masterdata/#api-Object_Types-OBJECTprojectMasterdata
    # the following attributes ar known
    # "project_id":"ABCD1234",
    # "project_name":"MyProject0815",
    # "description":"MyProject is about providing important things",
    # "parent_id":"DEF6789",
    # "additional_information": null,
    # "responsible_controller_id":"D000000",
    # "responsible_operator_email":"DL1337@sap.com",
    # "responsible_security_expert_id":"D000000",
    # "responsible_security_expert_email": "myName@sap.com",
    # "responsible_primary_contact_email": myName@sap.com,
    # "responsible_primary_contact_id": "D000000",
    # "responsible_product_owner_id":"D000000",
    # "responsible_product_owner_email": "myName@sap.com",
    # "responsible_controller_id":"D0000",
    # "responsible_controller_email": "myName@sap.com",
    # "revenue_relevance": "generating",
    # "business_criticality":"prod",
    # "number_of_endusers":100,
    # "cost_object": {
    #     "type": "IO",
    #     "name": "myIO"
    # }

    validates_presence_of :cost_object_type, :cost_object_name, unless: :cost_object_inherited
    validates_presence_of :responsible_primary_contact_id

    validates_presence_of :responsible_operator_id, unless: lambda { self.responsible_operator_email.blank? }, message: "can't be blank if operator email is defined"
    validates_presence_of :responsible_security_expert_id, unless: lambda { self.responsible_security_expert_email.blank? }, message: "can't be blank if security expert email is defined"
    validates_presence_of :responsible_product_owner_id, unless: lambda { self.responsible_product_owner_email.blank? }, message: "can't be blank if product owner email is defined"
    validates_presence_of :responsible_controller_id, unless: lambda { self.responsible_controller_email.blank? }, message: "can't be blank if controller email is defined"
    validates_presence_of :responsible_primary_contact_id, unless: lambda { self.responsible_primary_contact_email.blank? }, message: "can't be blank primary contact email is defined"

    validates_presence_of :responsible_operator_email, unless: lambda { self.responsible_operator_id.empty? }, message: "can't be blank if operator is defined"
    validates_presence_of :responsible_security_expert_email, unless: lambda { self.responsible_security_expert_id.blank? }, message: "can't be blank if security expert is defined"
    validates_presence_of :responsible_product_owner_email, unless: lambda { self.responsible_product_owner_id.blank? }, message: "can't be blank if product owner is defined"
    validates_presence_of :responsible_controller_email, unless: lambda { self.responsible_controller_id.blank? }, message: "can't be blank if controller is defined"
    validates_presence_of :responsible_primary_contact_email, unless: lambda { self.responsible_primary_contact_id.blank? }, message: "can't be blank if primary contact is defined"

    validates :number_of_endusers, :numericality => { :greater_than_or_equal_to => -1 },allow_nil: true,allow_blank: true

    validates :additional_information,
      length: { maximum: 5000, too_long: "5000 characters is the maximum allowed" }

    validates :responsible_operator_email,
      :responsible_security_expert_email,
      :responsible_product_owner_email,
      :responsible_controller_email,
      :responsible_primary_contact_email,
      format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "please use a valid email address" },
      allow_nil: true,
      allow_blank: true

    validates :responsible_operator_id,
      :responsible_security_expert_id,
      :responsible_primary_contact_id,
      :responsible_product_owner_id,
      :responsible_controller_id,
      format: { with: /\A[DCIdci]\d*\z/, message: "please use a C/D/I user id"},
      allow_nil: true,
      allow_blank: true

    def cost_object_name
      if read('cost_object_name') # from submit form
        read('cost_object_name')
      elsif cost_object # from api
        cost_object['name']
      else
        nil
      end
    end
 
    def cost_object_type
      if read('cost_object_type') # from submit form
        read('cost_object_type')
      elsif cost_object # from api
        cost_object['type']
      else
        nil
      end
    end

    def cost_object_inherited
      if read('cost_object_inherited') # from submit form
        read('cost_object_inherited') == "true"
      elsif cost_object # from api
        cost_object['inherited']
      else
        false
      end
    end

    def attributes_for_create
      params = {
        'project_id'                        => read('project_id'),
        'project_name'                      => read('project_name'),
        'parent_id'                         => read('domain_id'),
        'domain_id'                         => read('parent_id'),
        'description'                       => read('description'),
        'responsible_operator_id'           => read('responsible_operator_id'),
        'responsible_operator_email'        => read('responsible_operator_email'),
        'responsible_security_expert_id'    => read('responsible_security_expert_id'),
        'responsible_security_expert_email' => read('responsible_security_expert_email'),
        'responsible_primary_contact_id'    => read('responsible_primary_contact_id'),
        'responsible_primary_contact_email' => read('responsible_primary_contact_email'),
        'responsible_product_owner_id'      => read('responsible_product_owner_id'),
        'responsible_product_owner_email'   => read('responsible_product_owner_email'),
        'responsible_controller_id'         => read('responsible_controller_id'),
        'responsible_controller_email'      => read('responsible_controller_email'),
        'additional_information'            => read('additional_information'),
        'revenue_relevance'                 => read('revenue_relevance'),
        'business_criticality'              => read('business_criticality'),
        'number_of_endusers'                => read('number_of_endusers'),
      }.delete_if { |_k, v| v.blank? }
      
      if cost_object_inherited
        params['cost_object'] = {'inherited' => true}
      else
        params['cost_object'] = {
          'name' => cost_object_name,
          'type' => cost_object_type,
          'inherited' => cost_object_inherited
        }
      end
      
      params
    
    end

  end
end