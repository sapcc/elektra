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
    
    def self.revenue_relevances
      {
        'generating' => 'Generating',
        'enabling'   => 'Enabling',
        'other'      => 'Other',
      }
    end
    
    def self.business_criticalitys
      {
        'dev'  => 'Development',
        'test' => 'Testing',
        'prod' => 'Production',
      }
    end
    
  end
end
