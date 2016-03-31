module BlockStorage
  class Snapshot  < Core::ServiceLayer::Model
    validates :name, :description, presence: true
  end
end