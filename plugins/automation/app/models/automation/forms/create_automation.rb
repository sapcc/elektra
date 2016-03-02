module Automation

  class Forms::CreateAutomation
    include Virtus
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :type, String
    attribute :name, String
    attribute :project_id, String
    attribute :repository, String
    attribute :repository_revision, String
    attribute :tags, JSON
    attribute :timeout, Integer

    # chef
    attribute :run_list, Array[String]
    attribute :chef_attributes, JSON
    attribute :log_level, String

    # script
    attribute :path, String
    attribute :arguments, String
    attribute :environment, JSON

  end

end
