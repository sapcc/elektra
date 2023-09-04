
module Identity
  # https://stackoverflow.com/questions/4997762/ruby-on-rails-fully-functional-tableless-model?rq=1
  class Prodel
    include ActiveModel::Model

    validates_presence_of :project_name
    validates_format_of :project_name, :project_domain_name,
      :with => /\A(?:[^\s]+.*[^\s]+|)\Z/,
      :message => "could not start or end with whitepsace"

    attr_accessor :project_domain_name, :project_name
  end
end
