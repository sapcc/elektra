module BlockStorage
  class Volume  < Core::ServiceLayer::Model
    validates :name, :description, :size, presence: true
    attr_accessor :assigned_server
  end
end