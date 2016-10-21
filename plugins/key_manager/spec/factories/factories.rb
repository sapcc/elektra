module KeyManager

  class FakeFactory

    def secret(params = {})
      ::KeyManager::Secret.new({status: "ACTIVE",
                                secret_type: "certificate",
                                updated: "2016-10-17T14:30:26.168015",
                                name: "test certificate text_plain",
                                algorithm: nil,
                                created: "2016-10-17T14:30:26.155456",
                                content_types: {
                                  default: "text/plain"
                                },
                                creator_id: "916409a1dde718b39ab46e8f073855aa69450a455a14d7ea5064bbc41a5be4ea",
                                mode: nil,
                                bit_length: nil,
                                expiration: nil
                               }.merge(params))
    end

    def container(params = {})
      ::KeyManager::Container.new({status: "ACTIVE",
                                       updated: "2016-10-20T13:45:01.232805",
                                       name: "test container",
                                       consumers: [],
                                       created: "2016-10-20T13:45:01.232805",
                                       creator_id: "916409a1dde718b39ab46e8f073855aa69450a455a14d7ea5064bbc41a5be4ea",
                                       secret_refs: [{
                                                       secret_ref: "https://localhost:443/v1/secrets/4373e881-2f12-4c9f-b236-1e39738fae40",
                                                       name: "certificate"}
                                                    ],
                                       type: "certificate"
                                      }.merge(params))
    end

  end

end