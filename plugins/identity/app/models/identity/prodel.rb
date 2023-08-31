
module Identity
  # https://stackoverflow.com/questions/4997762/ruby-on-rails-fully-functional-tableless-model?rq=1
  class Prodel
    include ActiveModel::Model
    
    validates_presence_of :project_name

    attr_accessor :project_domain_name, :project_name
  end
end
