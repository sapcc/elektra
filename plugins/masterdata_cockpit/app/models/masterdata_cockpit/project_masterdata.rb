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
    # "responsible_primary_contact_email": myName@sap.com,
    # "responsible_primary_contact_id": "D000000",
    # "responsible_controller_id":"D0000",
    # "responsible_controller_email": "myName@sap.com",
    # "revenue_relevance": "generating",
    # "business_criticality":"prod",
    # "number_of_endusers":100,
    # "cost_object": {
    #     "type": "IO",
    #     "name": "myIO"
    # }

    validates_presence_of :environment, :type_of_data

    validates_presence_of :cost_object_type,
                          :cost_object_name,
                          unless: :cost_object_inherited

    validates_presence_of :business_criticality,
                          message:
                            "please choose the level of business criticality for your project"

    validates_presence_of :responsible_primary_contact_id,
                          if: -> { responsible_primary_contact_email.blank? },
                          message:
                            "please provide name or user. This is needed in case of emergency."
    validates_presence_of :responsible_primary_contact_email,
                          if: -> { responsible_primary_contact_id.blank? },
                          message:
                            "please provide contact information for this project (like a Email or DL). This is needed in case of emergency."

    validates_presence_of :responsible_operator_id,
                          if: -> { responsible_operator_email.blank? },
                          message:
                            "please provide name or user. This is needed in case of emergency."
    validates_presence_of :responsible_operator_email,
                          if: -> { responsible_operator_id.blank? },
                          message:
                            "please provide contact information for this project (like a Email or DL). This is needed in case of emergency."

    validates_presence_of :responsible_inventory_role_id,
                          if: -> { responsible_inventory_role_email.blank? },
                          message:
                            "please provide name or user. This is needed in case of emergency."

    validates_presence_of :responsible_inventory_role_email,
                          if: -> { responsible_inventory_role_id.blank? },
                          message:
                            "please provide contact information for this project (like a Email or DL). This is needed in case of emergency."

    validates_presence_of :additional_information,
                          if: -> { business_criticality == "prod_tc" },
                          message:
                            "can't be blank if business criticality is Productive Time Critical"

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

    validates :responsible_primary_contact_email,
              :responsible_operator_email,
              :responsible_inventory_role_email,
              :responsible_infrastructure_coordinator_email,
              format: {
                with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
                message: "please use a valid email/DL address",
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

    def type_of_data
      if read("type_of_data")
        read("type_of_data").gsub(/(&)/,"and")
      end
    end

    def attributes_for_create
      params = {
        "customer" => read("customer"),
        "project_id" => read("project_id"),
        "project_name" => read("project_name"),
        "parent_id" => read("domain_id"),
        "domain_id" => read("parent_id"),
        "description" => read("description"),
        "responsible_primary_contact_id" =>
          read("responsible_primary_contact_id") || "",
        "responsible_primary_contact_email" =>
          read("responsible_primary_contact_email") || "",
        "responsible_operator_id" => read("responsible_operator_id") || "",
        "responsible_operator_email" =>
          read("responsible_operator_email") || "",
        "responsible_inventory_role_id" =>
          read("responsible_inventory_role_id") || "",
        "responsible_inventory_role_email" =>
          read("responsible_inventory_role_email") || "",
        "responsible_infrastructure_coordinator_id" =>
          read("responsible_infrastructure_coordinator_id") || "",
        "responsible_infrastructure_coordinator_email" =>
          read("responsible_infrastructure_coordinator_email") || "",
        "additional_information" => read("additional_information") || "",
        "gpu_enabled" => read("gpu_enabled"),
        "contains_pii_dpp_hr" => read("contains_pii_dpp_hr"),
        "contains_external_customer_data" =>
          read("contains_external_customer_data"),
        "environment" => read("environment"),
        "ext_certification" => combine_external_certifications,
        "type_of_data" => read("type_of_data").gsub(/(and)/,"&"),
        "revenue_relevance" => read("revenue_relevance"),
        "business_criticality" => read("business_criticality"),
        "number_of_endusers" => read("number_of_endusers"),
      }

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
