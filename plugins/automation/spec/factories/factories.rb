module Automation

  class FakeFactory

    def job(params = {})
      ::Automation::Job.new({id: "test_job_1",
                           created_at: '2016-02-29T10:18:34.708279Z',
                           updated_at: '2016-02-29T10:18:49.708279Z',
                           payload: payload,
                           to: node.id}.merge(params))
    end

    def payload
      "This is a payload"
    end

    def payload_as_json
      '{"payload_test_as_json": ["role[landscape]","recipe[ids::certificate]"]}'
    end

    def log
      "This is a log"
    end

    def log_as_json
      '{"lo0g_test_as_json": ["miau","bup", "kuack"]}'
    end

    def node(params = {})
      ::Automation::Node.new({agent_id: "node_test_id",
                              project: "2c3d26747b1749f8b2abc8ce79dbf9c3",
                              organization: "ec213443e8834473b579f7bea9e8c194",
                              facts: facts,
                              tags:{"idp"=>"true", "name"=>"idp01", "pool"=>"green"},
                              created_at: "2016-08-01T13:02:29.088796Z",
                              updated_at: "2016-08-15T15:21:29.074271Z",
                              updated_with: "b34c1a20-b8be-4f96-8644-ee979f6f3f23",
                              updated_by: "api-p1nht"}.merge(params))
    end

    def facts(params = {})
      ::Automation::Facts.new({hostname: "idp01",
                               ipaddress: "10.0.0.104",
                               online: true,
                               os: "linux",
                               platform: "redhat",
                               platform_version: "7.2"}.merge(params))
    end

    def nodes
      {:elements=> [node],
       :total_elements=>1}
    end

    def jobs
      {:elements=> [job],
       :total_elements=>1}
    end

    def automations
      []
    end

    def automation_generic(params = {})
      ::Automation::Forms::Automation.new({"name"=>"test_automation", "repository"=>"http://test.com", "repository_revision"=>"master", "timeout"=>"3600", "type" => "test_type"}.merge(params))
    end

    def automation_chef(params = {})
      ::Automation::Forms::ChefAutomation.new({"name"=>"test_automation", "repository"=>"http://test.com", "repository_revision"=>"master", "timeout"=>"3600", "type" => "chef", "run_list" => "recipe[nginx]"}.merge(params))
    end

    def automation_script
    end

  end

end