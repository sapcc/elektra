module CostControl
  class DomainMasterdata < Core::ServiceLayer::Model
    # The following properties are known:
    # - cost_object_type (String)
    # - cost_object_id   (String)
    # - cost_object_responsibleController (String)
    # The id() is identical to the project ID if the object is persisted.

    COST_OBJECT_TYPES = {
      'CC'  => 'Cost Center',
      'IO'  => 'Internal Order',
      'PC'  => 'Profit Center',
      'SO'  => 'Sales Order',
      'WBS' => 'WBS element',
    }

    validates_presence_of :cost_object_type, :cost_object_id, :cost_object_responsibleController
    validates :cost_object_responsibleController, format: { with: /\A[DdIi]\d{6}\z/ }
    # TODO: validate cost_object_id

    def readable_cost_object_type
      type = cost_object_type
      type.blank? ? '' : "#{COST_OBJECT_TYPES[type]} (#{type})"
    end

  end
end
