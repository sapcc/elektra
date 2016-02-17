module Swift
  class Container < Core::ServiceLayer::Model

    # The following properties are known:
    #   - id (= name)
    #   - object_count
    #   - bytes_used

    # The Core::ServiceLayer::Model expects the object to be identified by
    # the `id` attribute. But Swift containers are identified by their name.
    # The driver maps the `name` attribute to "id" so that the Model base class
    # can grok it. This alias here should make high-level code using the model
    # class more readable.
    def name
      self.id
    end

  end
end
