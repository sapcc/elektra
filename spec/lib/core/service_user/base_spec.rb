require 'spec_helper'

describe Core::ServiceUser::Base do
  # Rails.configuration.keystone_endpoint = "http://localhost:5000/v3"
  # Rails.configuration.default_region = "eu-de-1"
  # Rails.configuration.service_user_id = "dashboard"
  # Rails.configuration.service_user_password = "dashboard"
  # Rails.configuration.service_user_domain_name = "monsooncc"
  
  # test domain name
  scope_test_domain = 'monsoon2'

  # test service user token. Key "value" was added manually to regard the format for auth user!
  service_user_test_token = {
    "expires_at"=>(Time.now+1.hour).to_s, # set expiration time to now + one hour
    "issued_at"=>Time.now.to_s,
    "methods"=>["password"],
    "catalog"=>[
      {
        "uri"=>"/services/s-00f9cb96c",
        "id"=>"s-00f9cb96c",
        "name"=>"Keystone V3",
        "description"=>"Monsoon Keystone V3 Service",
        "type"=>"identity",
        "links"=>{"self"=>"http://localhost:5000/v3/services/s-00f9cb96c"},
        "endpoints"=>[
          {
            "uri"=>"/endpoints/e-65b3d3da7",
            "id"=>"e-65b3d3da7",
            "name"=>"keystone-public-v3",
            "interface"=>"public",
            "links"=>{"self"=>"http://localhost:5000/v3/endpoints/e-65b3d3da7"},
            "service_id"=>"s-00f9cb96c",
            "region"=>Rails.configuration.default_region,
            "region_id"=>Rails.configuration.default_region,
            "url"=>Rails.configuration.keystone_endpoint
          }
        ]
      }
    ],
    "user"=>{
      "id"=>"u-dashboard",
      "name"=>Rails.configuration.service_user_id,
      "domain_id"=>"o-monsooncc",
      "default_project_id"=>nil,
      "links"=>{"self"=>"http://localhost:5000/v3/users/u-dashboard"},
      "domain"=>{"id"=>"o-monsooncc", "name"=>Rails.configuration.service_user_domain_name, "links"=>{"self"=>"http://localhost:5000/v3/domains/o-monsooncc"}}
    },
    "domain"=>{
      "uri"=>"/domains/o-monsoon2",
      "id"=>"o-#{scope_test_domain}",
      "name"=>scope_test_domain,
      "description"=>"Monsoon 2.0 Legacy Domain",
      "enabled"=>true,
      "links"=>{"self"=>"http://localhost:5000/v3/domains/o-monsoon2"}
    },
    "roles"=>[{"id"=>"r-admin", "links"=>{"self"=>"http://localhost:5000/v3/roles/r-admin"}, "name"=>"admin"}],
    "value"=>"5d8789290dd54e6694116d06bba67446"
  }
  
  let!(:service_user_driver){double("service user driver").as_null_object}
  
  before :each do
    @service_user_credentials = {
      scope_domain: scope_test_domain, 
      user_id: Rails.configuration.service_user_id,
      password: Rails.configuration.service_user_password,
      user_domain: Rails.configuration.service_user_domain_name
    }
    
    Core::ServiceUser::Base.instance_variable_set(:@service_users, nil)
    
    # stub service user using the test token
    allow(MonsoonOpenstackAuth.api_client).to receive(:auth_user).with(
      Rails.configuration.service_user_id,
      Rails.configuration.service_user_password,
      domain_name: Rails.configuration.service_user_domain_name,
      scoped_token: {domain: {name: scope_test_domain} }
    ).and_return(MonsoonOpenstackAuth::Authentication::AuthUser.new(service_user_test_token))

    # stub driver and return a null object
    allow(Fog::Identity::OpenStack::V3).to receive(:new).and_return(double("service user driver").as_null_object)
    #allow(Core::ServiceUser::Driver).to receive(:new).and_return(service_user_driver)
    allow(Core::ServiceUser::Base).to receive(:load).and_call_original
  end

  describe '::load' do
    before :each do
      # reset service_users cache
      Core::ServiceUser::Base.instance_variable_set(:@service_users, nil)
    end

    it 'returns a service user for a given domain' do
      expect(Core::ServiceUser::Base.load(@service_user_credentials)).not_to be(nil)
    end

    context 'service user is not initialized yet' do
      it 'should create a new service user' do
        expect(MonsoonOpenstackAuth.api_client).to receive(:auth_user)
        Core::ServiceUser::Base.load(@service_user_credentials)
      end
    end

    context 'service user already initialized' do
      before :each do
        Core::ServiceUser::Base.instance_variable_set(:@service_users, {scope_test_domain => Core::ServiceUser::Base.new(
          Rails.configuration.service_user_id,
          Rails.configuration.service_user_password,
          Rails.configuration.service_user_domain_name,
          scope_test_domain
        )
      })
      end

      it 'should not create a new service user' do
        expect(MonsoonOpenstackAuth.api_client).not_to receive(:auth_user)
        Core::ServiceUser::Base.load(@service_user_credentials)
      end
    end

    context 'service user already initialized but token is expired' do
      before :each do
        @service_user = Core::ServiceUser::Base.new(
          Rails.configuration.service_user_id,
          Rails.configuration.service_user_password,
          Rails.configuration.service_user_domain_name,
          scope_test_domain
        )

        allow(@service_user).to receive(:token_expired?).and_return(true)
        allow(@service_user.instance_variable_get(:@driver)).to receive(:get_user).with('u-7fd18a949').and_raise(Core::ServiceLayer::Errors::ApiError,
        'Expected([200]) <=> Actual(401 Invalid Credentials)
        excon.error.response
          :body          => "{\"error\":{\"code\":401,\"message\":\"Invalid Credentials\",\"title\":\"Not Found\"}}"
          :headers       => {
            "Cache-Control"          => "no-cache"
            "Connection"             => "keep-alive"
            "Content-Type"           => "application/json; charset=utf-8"
            "Date"                   => "Tue, 01 Mar 2016 12:54:44 GMT"
            "Server"                 => "nginx/1.4.4"
            "Status"                 => "404 Not Found"
            "X-Content-Type-Options" => "nosniff"
            "X-Frame-Options"        => "SAMEORIGIN"
            "X-Powered-By"           => "Phusion Passenger 4.0.33"
            "X-Request-Id"           => "e58a7413-3583-48d0-9db5-7b5e18c6ba5c"
            "X-Runtime"              => "0.012829"
            "X-XSS-Protection"       => "1; mode=block"
          }
          :local_address => "127.0.0.1"
          :local_port    => 52432
          :reason_phrase => "Not Found"
          :remote_ip     => "127.0.0.1"
          :status        => 404
          :status_line   => "HTTP/1.1 404 Not Found\r\n"
        ')  
        Core::ServiceUser::Base.instance_variable_set(:@service_users, {scope_test_domain => @service_user })
      end

      it 'should reauthenticate user' do
        expect(Core::ServiceUser::Base.load(@service_user_credentials).token_expired?).to eq(true)
        expect(@service_user).to receive(:authenticate)
        expect{
          Core::ServiceUser::Base.load(@service_user_credentials).find_user('u-7fd18a949')
        }.to raise_error(Core::ServiceLayer::Errors::ApiError)
      end
    end
  end

  describe 'delegated methods' do
    let!(:service_user){Core::ServiceUser::Base.load(@service_user_credentials)}

    it "should return token" do
      expect(service_user.token).not_to eq(service_user_test_token["value"])
    end

    it "should return token_expires_at" do
      expect(service_user.token_expires_at).to eq(service_user_test_token["expires_at"])
    end

    it "should return token_expired?" do
      expect(service_user.token_expired?).to eq(false)
    end

    it "should return scope domain id of service user" do
      expect(service_user.domain_id).to eq("o-#{scope_test_domain}")
    end

    it "should return scope domain name of service user" do
      expect(service_user.domain_name).to eq(scope_test_domain)
    end
  end

  describe 'instance methods' do
    let!(:service_user){Core::ServiceUser::Base.load(@service_user_credentials)}
    before :each do
      service_user = Core::ServiceUser::Base.load(scope_domain: scope_test_domain)

      user = {"id"=>"u-7fd18a949", "name"=>"D064310", "description"=>"Andreas Pfau", "email"=>"andreas.pfau@sap.com",
        "enabled"=>true, "domain_id"=>"o-monsoon2", "default_project_id"=>nil, "links"=>{"self"=>"http://localhost:5000/v3/users/u-7fd18a949"},
        "domain"=>{"id"=>"o-monsoon2", "name"=>"monsoon2", "links"=>{"self"=>"http://localhost:5000/v3/domains/o-monsoon2"}}
      }
      admin = {"id"=>"u-monsoon2_admin", "name"=>"Monsoon2 Admin", "description"=>"Admin", "email"=>"admin@sap.com",
        "enabled"=>true, "domain_id"=>"o-monsoon2", "default_project_id"=>nil, "links"=>{"self"=>"http://localhost:5000/v3/users/u-monsoon2_admin"},
        "domain"=>{"id"=>"o-monsoon2", "name"=>"monsoon2", "links"=>{"self"=>"http://localhost:5000/v3/domains/o-monsoon2"}}
      }
      dashboard = {"id"=>"u-dashboard", "name"=>"Dashboard Service User", "description"=>"Admin", "email"=>"dashboard@sap.com",
        "enabled"=>true, "domain_id"=>"o-monsoon2", "default_project_id"=>nil, "links"=>{"self"=>"http://localhost:5000/v3/users/u-dashboard"},
        "domain"=>{"id"=>"o-monsoon2", "name"=>"monsoon2", "links"=>{"self"=>"http://localhost:5000/v3/domains/o-monsoon2"}}
      }
      allow(service_user.instance_variable_get(:@driver)).to receive(:get_user).with('u-7fd18a949').and_return(user)
      allow(service_user.instance_variable_get(:@driver)).to receive(:get_user).with('u-monsoon2_admin').and_return(admin)
      allow(service_user.instance_variable_get(:@driver)).to receive(:get_user).with('u-dashboard').and_return(dashboard)

      project = {"uri"=>"/projects/o-2d4857817", "id"=>"o-2d4857817", "domain_id"=>"o-monsoon2", "name"=>"D064310",
        "description"=>"Andreas's Sandbox", "enabled"=>true, "parent_id"=>"o-test", "links"=>{"self"=>"http://localhost:5000/v3/projects/o-2d4857817"}
      }
      allow(service_user.instance_variable_get(:@driver)).to receive(:get_project).with('o-2d4857817').and_return(project)

      roles = [
        {"id"=>"r-admin", "links"=>{"self"=>"http://localhost:5000/v3/roles/r-admin"}, "name"=>"admin"},
        {"id"=>"r-member", "links"=>{"self"=>"http://localhost:5000/v3/roles/r-member"}, "name"=>"member"},
        {"id"=>"r-service", "links"=>{"self"=>"http://localhost:5000/v3/roles/r-service"}, "name"=>"service"}
      ]
      allow(service_user.instance_variable_get(:@driver)).to receive(:roles).and_return(roles)

      role_assignments = [
        {"scope"=>{"domain"=>{"id"=>"o-monsoon2"}}, "role"=>{"id"=>"r-admin"}, "user"=>{"id"=>"u-monsoon2_admin"}, "links"=>{"assignment"=>"http://localhost:5000/v3/domains/o-monsoon2/users/u-monsoon2_admin/roles/r-admin"}},
        {"scope"=>{"domain"=>{"id"=>"o-monsoon2"}}, "role"=>{"id"=>"r-admin"}, "user"=>{"id"=>"u-dashboard"}, "links"=>{"assignment"=>"http://localhost:5000/v3/domains/o-monsoon2/users/u-dashboard/roles/r-admin"}}
      ]
      allow(service_user.instance_variable_get(:@driver)).to receive(:role_assignments).with("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin').and_return(role_assignments)
      allow(service_user.instance_variable_get(:@driver)).to receive(:role_assignments).with("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin', effective: true).and_return(role_assignments)
    end


    describe '#find_user' do
      it "should return user" do
        expect(service_user.find_user('u-7fd18a949')).not_to be(nil)
      end

      it "should return an object of  Core::ServiceLayer::Model" do
        expect(service_user.find_user('u-7fd18a949').class).to be(Core::ServiceLayer::Model)
      end

      it "should return name" do
        expect(service_user.find_user('u-7fd18a949').name).to eq('D064310')
      end

      it "should return domain as hash" do
        expect(service_user.find_user('u-7fd18a949').domain.class).to be(Hash)
      end
    end

    describe '#find_project_by_name_or_id' do
      it "should return project" do
        expect(service_user.find_project_by_name_or_id('o-2d4857817')).not_to be(nil)
      end

      it "should return an object of Core::ServiceLayer::Model" do
        expect(service_user.find_project_by_name_or_id('o-2d4857817').class).to be(Core::ServiceLayer::Model)
      end

      it "should return name" do
        expect(service_user.find_project_by_name_or_id('o-2d4857817').name).to eq('D064310')
      end

      it "should return parent id" do
        expect(service_user.find_project_by_name_or_id('o-2d4857817').parent_id).to eq("o-test")
      end
    end

    describe '#roles' do

      it "should return an array" do
        expect(service_user.roles.class).to be(Array)
      end

      it "should contains Core::ServiceLayer::Model objects" do
        expect(service_user.roles.first.class).to be(Core::ServiceLayer::Model)
      end

      it "should respond to id" do
        expect(service_user.roles.first).to respond_to(:id)
      end

      it "should respond to name" do
        expect(service_user.roles.first).to respond_to(:name)
      end

      it "should return the id" do
        expect(service_user.roles.first.id).to eq("r-admin")
      end
    end

    describe '#role_assignments' do

      it "should return an array" do
        expect(service_user.role_assignments("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin').class).to be(Array)
      end

      it "should contains Core::ServiceLayer::Model objects" do
        expect(service_user.role_assignments("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin').first.class).to be(Core::ServiceLayer::Model)
      end

      it "should respond to scope" do
        expect(service_user.role_assignments("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin').first).to respond_to(:scope)
      end

      it "should respond to role" do
        expect(service_user.role_assignments("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin').first).to respond_to(:role)
      end

      it "should return the role as Hash" do
        expect(service_user.role_assignments("scope.domain.id"=>"o-#{scope_test_domain}","role.id"=>'r-admin').first.role.class).to be(Hash)
      end
    end

    describe '#find_role_by_name' do

      it "should return role" do
        expect(service_user.find_role_by_name('admin')).not_to be(nil)
      end

      it "should return an object of Core::ServiceLayer::Model" do
        expect(service_user.find_role_by_name('admin').class).to be(Core::ServiceLayer::Model)
      end

      it "should return id" do
        expect(service_user.find_role_by_name('admin').id).to eq('r-admin')
      end
    end

    describe '#grant_user_domain_member_role' do
      it "should create a role_assignment" do
        expect(service_user.instance_variable_get(:@driver)).to receive(:grant_domain_user_role).with("o-#{scope_test_domain}",'u-7fd18a949','r-admin')
        service_user.grant_user_domain_member_role('u-7fd18a949','admin')
      end
    end

    describe '#list_scope_assigned_users!' do
      let!(:role){double("admin role",id:'r-admin',name:'admin')}
      it 'should return an array' do
        expect(service_user.list_scope_assigned_users!(domain_id: "o-#{scope_test_domain}", role: role).class).to be(Array)
      end

      it 'returns one admin' do
        expect(service_user.list_scope_assigned_users!(domain_id: "o-#{scope_test_domain}", role: role).length).to eq(1)
      end

      it 'returns monsoon2_admin' do
        admins = service_user.list_scope_assigned_users!(domain_id: "o-#{scope_test_domain}", role: role)
        expect(admins.collect{|a|a.id}.sort).to eq(["u-monsoon2_admin"])
      end
    end
  end

  context 'token was revoked' do
    before :each do
      #allow(@service_user.instance_variable_get(:@driver)).to receive(:role_assignments).and_raise
    end

  end
end

