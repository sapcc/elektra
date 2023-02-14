# frozen_string_literal: true

require "masterdata_cockpit/engine"

module MasterdataCockpit
  # Config
  class Config
    def self.cost_object_types
      {
        "CC" => "Cost Center",
        "IO" => "Internal Order",
        "SO" => "Sales Order",
        "WBS" => "WBS Element",
      }
    end

    def self.ext_certification
      {
        "iso" => "ISO",
        "pci" => "PCI",
        "soc1" => "SOC1",
        "soc2" => "SOC2",
        "c5" => "C5",
        "sox" => "SOX",
      }
    end

    def self.soft_license_mode
      {
        "Revenue Generating" => "Revenue Generating",
        "Training and Demo" => "Training & Demo",
        "Development" => "Development",
        "Test and QS" => "Test & QS",
        "Administration" => "Administration",
        "Make" => "Make",
        "Virtualization-Host" => "Virtualization-Host",
        "Productive" => "Productive",
      }
    end

    def self.environment
      {
        "Prod" => "Production",
        "QA" => "QA",
        "Admin" => "Admininstration",
        "DEV" => "Development",
        "Demo" => "Demo",
        "Train" => "Training",
        "Sandbox" => "Sandbox",
        "Lab" => "Lab",
        "Test" => "Testing",
      }
    end

    def self.type_of_data
      {
        "SAP Business Proces" => "SAP Business Process",
        "Customer Cloud Service" => "Customer Cloud Service",
        "Customer Business Process" => "Customer Business Process",
        "Training and Demo" => "Training & Demo",
        "Cloud" => "Cloud",
      }
    end

    def self.revenue_relevances
      {
        "generating" => "Generating",
        "enabling" => "Enabling",
        "other" => "Other",
      }
    end

    def self.business_criticalitys
      {
        "dev" => "Development",
        "test" => "Testing",
        "prod" => "Production",
        "prod_tc" => "Production Time Critical",
      }
    end
  end
end
