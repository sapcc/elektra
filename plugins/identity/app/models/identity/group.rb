module Identity
  class Group < Core::ServiceLayer::Model
    validates :name, presence: {message: 'Please provide a name for this group.'}
  end
end