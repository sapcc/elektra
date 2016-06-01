module CostControl
  class ProjectMetadata < Core::ServiceLayer::Model
    # The following properties are known:
    # - project_name
    # - domain_name
    # - cost_object
    # The id() is identical to the project ID if the object is persisted.

    validates_presence_of :project_name, :domain_name
    # TODO: validation for cost_object

  end
end
