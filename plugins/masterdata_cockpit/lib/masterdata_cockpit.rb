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
    
  end
end
