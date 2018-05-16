# frozen_string_literal: true

require 'spec_helper'

describe Lookup::ReverseLookupController, type: :controller do
  # render_views
  routes { Lookup::Engine.routes }

  default_params = { domain_id: AuthenticationStub.domain_id }

  before(:all) do
    FriendlyIdEntry.find_or_create_entry(
      'Domain',
      nil,
      default_params[:domain_id],
      'default'
    )
  end

  before :each do
    stub_authentication do |token|
      token['roles'] << { 'id' => '2', 'name' => 'admin' }
      token.delete('project')
      token['domain'] = { 'id' => 'default', 'name' => 'default' }
      token
    end
    allow(UserProfile).to receive(:tou_accepted?).and_return true
  end

  describe "POST 'search'" do
    context 'IP' do
      it 'returns http success' do
        @ip_obj = double('ip test',
                         id:                   'ip_test_id',
                         floating_ip_address:  'ip_test_name',
                         tenant_id:            'ip_test_tenant_id',
                         'blank?' => false)

        allow(controller.cloud_admin)
          .to receive(:floating_ips).and_return(
            [@ip_obj]
          )

        post :search, params: default_params.merge(searchValue: '10.47.43.95')
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['searchValue']).to eq('10.47.43.95')
        expect(body['searchBy']).to eq('ip')
        expect(body['id']).to eq(@ip_obj.id)
        expect(body['name']).to eq(@ip_obj.floating_ip_address)
        expect(body['projectId']).to eq(@ip_obj.tenant_id)
      end

      it 'returns 404' do
        allow(controller.cloud_admin)
          .to receive(:floating_ips).and_return(
            []
          )
        post :search, params: default_params.merge(searchValue: '10.47.43.95')
        expect(response).to_not be_success
        expect(response.status).to eq(404)
        body = JSON.parse(response.body)
        expect(body['searchValue']).to eq('10.47.43.95')
        expect(body['searchBy']).to eq('ip')
      end
    end

    context 'Instance' do
      it 'returns http success' do
        @instance_obj = double('instance_test',
                               id:                   'instance_test_id',
                               name:  'instance_test_name',
                               project_id:            'instance_test_tenant_id',
                               'blank?' => false)
        allow(controller.cloud_admin)
          .to receive(:find_server).and_return(
            @instance_obj
          )
        post :search, params: default_params.merge(searchValue: '852588dd-3f7a-4d8a-a3f3-8f2792fbcd14')
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['searchValue']).to eq('852588dd-3f7a-4d8a-a3f3-8f2792fbcd14')
        expect(body['searchBy']).to eq('instance')
        expect(body['id']).to eq(@instance_obj.id)
        expect(body['name']).to eq(@instance_obj.name)
        expect(body['projectId']).to eq(@instance_obj.project_id)
      end
      it 'returns 404' do
        allow(controller.cloud_admin)
          .to receive(:find_server).and_return(
            nil
          )
        post :search, params: default_params.merge(searchValue: '852588dd-3f7a-4d8a-a3f3-8f2792fbcd14')
        expect(response).to_not be_success
        expect(response.status).to eq(404)
        body = JSON.parse(response.body)
        expect(body['searchValue']).to eq('852588dd-3f7a-4d8a-a3f3-8f2792fbcd14')
        expect(body['searchBy']).to eq('instance')
      end
    end

    context 'DNS' do
      it 'returns http success' do
        @dns_obj = double('zone_test',
                          id:                   'dns_test_id',
                          name:  'dns_test_name',
                          project_id:            'dns_test_tenant_id',
                          'blank?' => false)
        allow(controller.cloud_admin)
          .to receive(:zones).and_return(
            items: [@dns_obj]
          )
        post :search, params: default_params.merge(searchValue: 'bh11.c.eu-nl-1.cloud.sap.')
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['searchValue']).to eq('bh11.c.eu-nl-1.cloud.sap.')
        expect(body['searchBy']).to eq('dns')
        expect(body['id']).to eq(@dns_obj.id)
        expect(body['name']).to eq(@dns_obj.name)
        expect(body['projectId']).to eq(@dns_obj.project_id)
      end
    end
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get :index, params: default_params
      expect(response).to be_success
      expect(response).to render_template('index')
    end
  end
  # Elektron::Errors::ApiResponse.new(double('exception', code: 404))

  describe "GET 'domain'" do
    before :each do
      allow(controller.cloud_admin)
        .to receive(:find_project).and_return(
          double('project', domain_id: 'some_domain_id')
        )
    end

    it 'should http success' do
      @domain_obj = double('domain_test',
                           id:          'domain_test_id',
                           name:        'domain_test_name',
                           project_id:  'domain_test_tenant_id',
                           'blank?' => false)
      allow(controller.cloud_admin)
        .to receive(:find_domain).and_return(
          @domain_obj
        )
      get :domain, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it 'should return 404' do
      allow(controller.cloud_admin)
        .to receive(:find_domain).and_return(
          nil
        )
      get :domain, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to_not be_success
      expect(response.status).to eq(404)
      body = JSON.parse(response.body)
      expect(body['projectId']).to eq('123456789')
    end
  end

  describe "GET 'parents'" do
    it 'should http success' do
      allow(controller.cloud_admin)
        .to receive(:find_project).and_return(
          double('project', parents: {}, name: 'test')
        )

      @parents_obj = double('parents_test',
                            id:          'domain_test_id',
                            name:        'domain_test_name',
                            project_id:  'domain_test_tenant_id',
                            'blank?' => false)
      get :parents, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it 'should return 404' do
      allow(controller.cloud_admin)
        .to receive(:find_project).and_return(
          nil
        )
      get :parents, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to_not be_success
      expect(response.status).to eq(404)
      body = JSON.parse(response.body)
      expect(body['projectId']).to eq('123456789')
    end
  end

  describe "GET 'users'" do
    it 'should http success' do
      allow(controller.cloud_admin)
        .to receive(:find_role_by_name).and_return(
          double('role', id: 'test_id')
        )
      allow(controller.cloud_admin)
        .to receive(:role_assignments).and_return(
          [double('assigment', user: { 'id' => 'bceceac0b63358198e9daa85bf82c215dec4d960423497f9e780326d48c316d7', 'name' => 'I318336' })]
        )
      get :users, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end
  end

  describe "GET 'groups'" do
    it 'should http success' do
      allow(controller.cloud_admin)
        .to receive(:find_role_by_name).and_return(
          double('role', id: 'test_id')
        )
      allow(controller.cloud_admin)
        .to receive(:role_assignments).and_return(
          [double('assigment', group: { 'id' => 'bceceac0b63358198e9daa85bf82c215dec4d960423497f9e780326d48c316d7', 'name' => 'ADMIN' })]
        )
      get :groups, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end
  end

  describe "GET 'group_members'" do
    it 'should http success' do
      allow(controller.cloud_admin)
        .to receive(:group_members).and_return(
          [double('group_member', id: 'test_id', name: 'test_name', description: 'test_description')]
        )
      get :group_members, params: default_params.merge(reverseLookupGrouptId: '123456789')
      expect(response).to be_success
      expect(response.body).to_not be_nil
    end

    it 'should return 404' do
      allow(controller.cloud_admin)
        .to receive(:group_members).and_return(
          nil
        )
      get :parents, params: default_params.merge(reverseLookupProjectId: '123456789')
      expect(response).to_not be_success
      expect(response.status).to eq(404)
      body = JSON.parse(response.body)
      expect(body['projectId']).to eq('123456789')
    end
  end
  describe "GET 'object_info'" do
    context 'IP' do
      it 'should http success' do
        @ip_obj = double('ip',
                         id:                   'ip_test_id',
                         port_id: 'abcdfg',
                         'blank?' => false)
        @port_obj = double('port',
                           id: 'port_test_id')

        allow(controller.cloud_admin)
          .to receive(:find_floating_ip).and_return(
            @ip_obj
          )
        allow(controller.cloud_admin)
          .to receive(:find_port).and_return(
            @port_obj
          )
        get :object_info, params: default_params.merge(reverseLookupObjectId: '123456789', searchBy: Lookup::ReverseLookupController::SEARCHBY[:ip])
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['searchBy']).to eq(Lookup::ReverseLookupController::SEARCHBY[:ip])
        expect(body['searchObjectId']).to eq('123456789')
        expect(body['detailsTitle']).to eq('Port information')
        expect(body['details'].to_json).to eq(@port_obj.to_json)
      end
      it 'should return 404' do
        allow(controller.cloud_admin)
          .to receive(:find_floating_ip).and_return(
            nil
          )
        get :object_info, params: default_params.merge(reverseLookupObjectId: '123456789', searchBy: Lookup::ReverseLookupController::SEARCHBY[:ip])
        expect(response).to_not be_success
        body = JSON.parse(response.body)
        expect(body['searchBy']).to eq(Lookup::ReverseLookupController::SEARCHBY[:ip])
        expect(body['searchObjectId']).to eq('123456789')
      end
    end
    context 'DNS' do
      it 'returns http success' do
        @recordsets_obj = double('recordsets_test',
                                 id: 'recordset_test_id')
        allow(controller.cloud_admin)
          .to receive(:recordsets).and_return(
            items: [@recordsets_obj]
          )
        get :object_info, params: default_params.merge(reverseLookupObjectId: '123456789', searchBy: Lookup::ReverseLookupController::SEARCHBY[:dns])
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['searchBy']).to eq(Lookup::ReverseLookupController::SEARCHBY[:dns])
        expect(body['searchObjectId']).to eq('123456789')
        expect(body['detailsTitle']).to eq('Recordsets information')
        expect(body['details'].to_json).to eq([@recordsets_obj].to_json)
      end
      it 'should return 404' do
        allow(controller.cloud_admin)
          .to receive(:recordsets).and_return(
            items: []
          )
        get :object_info, params: default_params.merge(reverseLookupObjectId: '123456789', searchBy: Lookup::ReverseLookupController::SEARCHBY[:dns])
        expect(response).to_not be_success
        expect(response.status).to eq(404)
        body = JSON.parse(response.body)
        expect(body['searchBy']).to eq(Lookup::ReverseLookupController::SEARCHBY[:dns])
        expect(body['searchObjectId']).to eq('123456789')
      end
    end
    context 'Instance' do
      it 'should http success' do
        @instance_obj = double('instance_test',
                               id:                   'instance_test_id',
                               name:  'instance_test_name',
                               project_id:            'instance_test_tenant_id',
                               'blank?' => false)
        allow(controller.cloud_admin)
          .to receive(:find_server).and_return(
            @instance_obj
          )
        get :object_info, params: default_params.merge(reverseLookupObjectId: '123456789', searchBy: Lookup::ReverseLookupController::SEARCHBY[:instance])
        expect(response).to be_success
        body = JSON.parse(response.body)
        expect(body['searchBy']).to eq(Lookup::ReverseLookupController::SEARCHBY[:instance])
        expect(body['searchObjectId']).to eq('123456789')
        expect(body['detailsTitle']).to eq('Compute instance information')
        expect(body['details'].to_json).to eq(@instance_obj.to_json)
      end
      it 'should return 404' do
        allow(controller.cloud_admin)
          .to receive(:find_server).and_return(
            nil
          )
        get :object_info, params: default_params.merge(reverseLookupObjectId: '123456789', searchBy: Lookup::ReverseLookupController::SEARCHBY[:instance])
        expect(response).to_not be_success
        expect(response.status).to eq(404)
        body = JSON.parse(response.body)
        expect(body['searchBy']).to eq(Lookup::ReverseLookupController::SEARCHBY[:instance])
        expect(body['searchObjectId']).to eq('123456789')
      end
    end
  end
end
