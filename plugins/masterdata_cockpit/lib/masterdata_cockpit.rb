require "masterdata_cockpit/engine"
# use misty with our converged cloud extension
require 'misty/openstack/cc'

module MasterdataCockpit
  class Config
    
    def self.cost_object_types
      {
        'CC'  => 'Cost Center',
        'IO'  => 'Internal Order',
        'SO'  => 'Sales Order',
        'WBS' => 'WBS element',
      }
    end
    
    def self.solutions
      # from /masterdata/solutions/
      [
        "S/4 Marketing",
        "S/4 Public Cloud",
        "IBP",
        "BizX",
        "Wokforce Planning and Analytics",
        "Learning",
        "Onboarding",
        "Recruiting",
        "Mobile",
        "JAM",
        "Payroll",
        "Workforce Performance Builder",
        "Cloud for Customer",
        "hybris",
        "Cloud for Analytics",
        "SAP Cloud Platfrom",
        "Sports One",
        "Stewardship Network",
        "Vehicles Insights",
        "Vehicles Network",
        "PDMS Cloud Edition",
        "App Services",
        "Two Go",
        "BUILD",
        "Anywhere",
        "C4TE",
        "BYD",
        "C4C",
        "CfTE",
        "Event Ticketing",
        "HCP",
        "NON- Payroll HCM",
        "S/4 HANA"
      ]
    end
  end
end
