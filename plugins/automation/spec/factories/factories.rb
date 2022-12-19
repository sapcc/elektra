module Automation
  class FakeFactory
    def job(params = {})
      ::Automation::Job.new(
        {
          id: "test_job_1",
          created_at: "2016-02-29T10:18:34.708279Z",
          updated_at: "2016-02-29T10:18:49.708279Z",
          payload: payload,
          to: node.id,
        }.merge(params),
      )
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
      ::Automation::Node.new(
        {
          agent_id: "node_test_id",
          project: "2c3d26747b1749f8b2abc8ce79dbf9c3",
          organization: "ec213443e8834473b579f7bea9e8c194",
          facts: facts,
          tags: {
            "idp" => "true",
            "name" => "idp01",
            "pool" => "green",
          },
          created_at: "2016-08-01T13:02:29.088796Z",
          updated_at: "2016-08-15T15:21:29.074271Z",
          updated_with: "b34c1a20-b8be-4f96-8644-ee979f6f3f23",
          updated_by: "api-p1nht",
        }.merge(params),
      )
    end

    def facts(params = {})
      ::Automation::Facts.new(
        {
          hostname: "idp01",
          ipaddress: "10.0.0.104",
          online: true,
          os: "linux",
          platform: "redhat",
          platform_version: "7.2",
        }.merge(params),
      )
    end

    def nodes
      { elements: [node], total_elements: 1 }
    end

    def jobs
      { elements: [job], total_elements: 1 }
    end

    def automations
      []
    end

    def automation_form_generic(params = {})
      ::Automation::Forms::Automation.new(
        {
          "name" => "test_automation",
          "repository" => "http://test.com",
          "repository_revision" => "master",
          "timeout" => "3600",
          "type" => "test_type",
        }.merge(params),
      )
    end

    def automation_form_chef(params = {})
      ::Automation::Forms::ChefAutomation.new(
        {
          "name" => "test_automation",
          "repository" => "http://test.com",
          "repository_revision" => "master",
          "timeout" => "3600",
          "type" => "chef",
          "run_list" => "recipe[nginx]",
        }.merge(params),
      )
    end

    def automation(params = {})
      ::Automation::Automation.site = "https://test.com"
      automation =
        ::Automation::Automation.new(
          {},
          {
            name: "bootstrap",
            timeout: 3600,
            run_list: ["role[landscape]", "recipe[ids::certificate]"],
            repository: "https://github.com/sapcc/chef-test.git",
          }.merge(params),
        )
      automation
    end

    def run(params = {})
      ::Automation::Run.site = "https://test.com"
      run =
        ::Automation::Run.new(
          {},
          {
            id: 165,
            log:
              "Selecting nodes using filter @identity='idp1':\nidp1 idp01\nUsing exiting artifact for revision c7b3ee00635673294619070fafbccf27a23bcbd4\nScheduled 1 job:\n376f5485-9d2e-4040-a55f-7e42ea6d6a7b\n",
            created_at: "2016-08-18T15:33:57.133Z",
            updated_at: "2016-08-18T15:35:21.468Z",
            repository_revision: "c7b3ee00635673294619070fafbccf27a23bcbd4",
            state: "completed",
            jobs: ["376f5485-9d2e-4040-a55f-7e42ea6d6a7b"],
            owner: {
              id:
                "b2ff8f4a7d1eab4f5cf82489f76e52fc1934c1b4d4a7a4a9bd9ce82ca1310bbc",
              name: "Musterman",
              domain_id: "ec213443e8834473b579f7bea9e8c194",
              domain_name: "monsoon3",
              chef_attributes: {
              },
              repository_revision: "",
            },
            automation_id: "5",
            automation_name: "bootstrap",
            selector: "@identity='idp1'",
            automation_attributes: automation.attributes,
          }.merge(params),
        )
      run
    end
  end
end
