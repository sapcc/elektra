# frozen_string_literal: true

module MasterdataCockpit
  class ProjectMasterdata < Core::ServiceLayer::Model
    # https://billing.eu-de-2.cloud.sap:64000/masterdata/
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

    validates_presence_of :cost_object_type,
                          :cost_object_name,
                          unless: :cost_object_inherited
    validates_presence_of :business_criticality,
                          message:
                            "please choose the level of business criticality for your project"
    validates_presence_of :responsible_primary_contact_id,
                          message:
                            "please provide the primary contact information for this project. This is needed in case of emergency"
    validates_presence_of :responsible_security_expert_id,
                          message:
                            "please provide the contact information for your security expert that is responsibly for the project"

    validates_presence_of :responsible_operator_id,
                          unless: -> { responsible_operator_email.blank? },
                          message: "can't be blank if operator email is defined"
    validates_presence_of :responsible_security_expert_id,
                          unless: -> {
                            responsible_security_expert_email.blank?
                          },
                          message:
                            "can't be blank if security expert email is defined"
    validates_presence_of :responsible_product_owner_id,
                          unless: -> { responsible_product_owner_email.blank? },
                          message:
                            "can't be blank if product owner email is defined"
    validates_presence_of :responsible_controller_id,
                          unless: -> { responsible_controller_email.blank? },
                          message:
                            "can't be blank if controller email is defined"
    validates_presence_of :responsible_primary_contact_id,
                          unless: -> {
                            responsible_primary_contact_email.blank?
                          },
                          message:
                            "can't be blank primary contact email is defined"

    validates_presence_of :responsible_operator_email,
                          unless: -> { responsible_operator_id.blank? },
                          message: "can't be blank if operator is defined"
    validates_presence_of :responsible_security_expert_email,
                          unless: -> { responsible_security_expert_id.blank? },
                          message:
                            "can't be blank if security expert is defined"
    validates_presence_of :responsible_product_owner_email,
                          unless: -> { responsible_product_owner_id.blank? },
                          message: "can't be blank if product owner is defined"
    validates_presence_of :responsible_controller_email,
                          unless: -> { responsible_controller_id.blank? },
                          message: "can't be blank if controller is defined"
    validates_presence_of :responsible_primary_contact_email,
                          unless: -> { responsible_primary_contact_id.blank? },
                          message:
                            "can't be blank if primary contact is defined"

    validates_presence_of :inventory_role,
                          :infrastructure_coordinator,
                          :responsible_operator_id

    validates_presence_of :additional_information,
                          if: -> { business_criticality == "prod_tc" },
                          message:
                            "can't be blank if business criticality is Productive Time Critical"
    validates_presence_of :environment, :type_of_data, :soft_license_mode

    validates :number_of_endusers,
              numericality: {
                greater_than_or_equal_to: -1,
              },
              allow_nil: true,
              allow_blank: true

    validates :additional_information,
              length: {
                maximum: 5000,
                too_long: "5000 characters is the maximum allowed",
              }

    # limit from billing api and keystone
    validates :description,
              length: {
                maximum: 255,
                too_long: "255 characters is the maximum allowed",
              }

    validates :responsible_operator_email,
              :responsible_security_expert_email,
              :responsible_product_owner_email,
              :responsible_controller_email,
              :responsible_primary_contact_email,
              format: {
                with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
                message: "please use a valid email/DL address",
              },
              allow_nil: true,
              allow_blank: true

    validates :infrastructure_coordinator,
              format: {
                with: /\A[DCIdci]\d*\z/,
                message: "please use a C/D/I user id",
              },
              allow_nil: true,
              allow_blank: true

    def cost_object_name
      if read("cost_object_name")
        # from submit form
        read("cost_object_name")
      elsif cost_object
        # from api
        cost_object["name"]
      end
    end

    def cost_object_type
      if read("cost_object_type")
        # from submit form
        read("cost_object_type")
      elsif cost_object
        # from api
        cost_object["type"]
      end
    end

    def cost_object_inherited
      if read("cost_object_inherited")
        # from submit form
        read("cost_object_inherited") == "true"
      elsif cost_object
        # from api
        cost_object["inherited"]
      else
        false
      end
    end

    def combine_external_certifications
      {
        "iso" => read("ext_cert_iso"),
        "c5" => read("ext_cert_c5"),
        "pci" => read("ext_cert_pci"),
        "soc1" => read("ext_cert_soc1"),
        "soc2" => read("ext_cert_soc2"),
        "sox" => read("ext_cert_sox"),
      }
    end

    def ext_cert_iso
      if read("ext_cert_iso")
        # from submit form
        read("ext_cert_iso")
      else
        read("ext_certification")["iso"] # from api
      end
    end

    def ext_cert_c5
      if read("ext_cert_c5")
        # from submit form
        read("ext_cert_c5")
      else
        read("ext_certification")["c5"] # from api
      end
    end

    def ext_cert_pci
      if read("ext_cert_pci")
        # from submit form
        read("ext_cert_pci")
      else
        read("ext_certification")["pci"] # from api
      end
    end

    def ext_cert_soc1
      if read("ext_cert_soc1")
        # from submit form
        read("ext_cert_soc1")
      else
        read("ext_certification")["soc1"] # from api
      end
    end

    def ext_cert_soc2
      if read("ext_cert_soc2")
        # from submit form
        read("ext_cert_soc2")
      else
        read("ext_certification")["soc2"] # from api
      end
    end

    def ext_cert_sox
      if read("ext_cert_sox")
        # from submit form
        read("ext_cert_sox")
      else
        read("ext_certification")["sox"] # from api
      end
    end

    def attributes_for_create
      params =
        {
          "customer" => read("customer"),
          "project_id" => read("project_id"),
          "project_name" => read("project_name"),
          "parent_id" => read("domain_id"),
          "domain_id" => read("parent_id"),
          "description" => read("description"),
          "responsible_operator_id" => read("responsible_operator_id"),
          "responsible_operator_email" => read("responsible_operator_email"),
          "responsible_security_expert_id" =>
            read("responsible_security_expert_id"),
          "responsible_security_expert_email" =>
            read("responsible_security_expert_email"),
          "responsible_primary_contact_id" =>
            read("responsible_primary_contact_id"),
          "responsible_primary_contact_email" =>
            read("responsible_primary_contact_email"),
          "responsible_product_owner_id" =>
            read("responsible_product_owner_id"),
          "responsible_product_owner_email" =>
            read("responsible_product_owner_email"),
          "responsible_controller_id" => read("responsible_controller_id"),
          "responsible_controller_email" =>
            read("responsible_controller_email"),
          "biso" => read("biso"),
          "supervisor" => read("supervisor"),
          "inventory_role" => read("inventory_role"),
          "infrastructure_coordinator" => read("infrastructure_coordinator"),
          "additional_information" => read("additional_information"),
          "gpu_enabled" => read("gpu_enabled"),
          "contains_pii_dpp_hr" => read("contains_pii_dpp_hr"),
          "contains_external_customer_data" =>
            read("contains_external_customer_data"),
          "environment" => read("environment"),
          "ext_certification" => combine_external_certifications,
          "type_of_data" => read("type_of_data"),
          "soft_license_mode" => read("soft_license_mode"),
          "revenue_relevance" => read("revenue_relevance"),
          "business_criticality" => read("business_criticality"),
          "number_of_endusers" => read("number_of_endusers"),
        }.delete_if { |_k, v| v.blank? }

      params["cost_object"] = if cost_object_inherited
        { "inherited" => true }
      else
        {
          "name" => cost_object_name,
          "type" => cost_object_type,
          "inherited" => cost_object_inherited,
        }
      end

      params
    end
  end
end
