module CostControl
  class ProjectMetadata < Core::ServiceLayer::Model
    # The following properties are known:
    # - cost_object_type (String)
    # - cost_object_id   (String)
    # The id() is identical to the project ID if the object is persisted.

    COST_OBJECT_TYPES = {
      'CC'  => 'Cost Center',
      'IO'  => 'Internal Order',
      'PC'  => 'Profit Center',
      'SO'  => 'Sales Order',
      'WBS' => 'WBS element',
    }

    validates_presence_of :cost_object_type, :cost_object_id
    # TODO: validate values

  end
end
