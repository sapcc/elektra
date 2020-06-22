# frozen_string_literal: true

require 'masterdata_cockpit/engine'

module MasterdataCockpit
  # Config
  class Config
    def self.cost_object_types
      {
        'CC' => 'Cost Center',
        'IO' => 'Internal Order',
        'SO' => 'Sales Order',
        'WBS' => 'WBS Element'
      }
    end

    def self.revenue_relevances
      {
        'generating' => 'Generating',
        'enabling' => 'Enabling',
        'other' => 'Other'
      }
    end

    def self.business_criticalitys
      {
        'dev' => 'Development',
        'test' => 'Testing',
        'prod' => 'Production',
        'prod_tc' => 'Production Time Critical'
      }
    end
  end
end
