module ServiceLayer
  class EmailServiceService < Core::ServiceLayer::Service
    include EmailServiceServices::NebulaAccount

    # Work in Progress

    def available?(_action_name_sym = nil)
      elektron.service?("nebula")
    end

    def elektron_nebula(options = {})
      @elektron_nebula ||=
        elektron_nebula_client.get("/v3/aws/#{options.project_id}")
    end

    def elektron_nebula_client(auth_conf, options = {})
      @elektron_nebula_client ||= Elektron.client(auth_conf, options)
    end

    def elektron_email
      @elektron_cronus ||= elektron.service("email-aws", path_prefix: "/v3")
    end
  end
end
