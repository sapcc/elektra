module ObjectStorage
  class Container < Core::ServiceLayer::Model

    # The following properties are known:
    #   - name
    #   - object_count
    #   - bytes_used
    # The id() is identical to the name() if the container is persisted.

  end
end
