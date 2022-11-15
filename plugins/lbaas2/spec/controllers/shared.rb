RSpec.shared_examples 'index action' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns http success' do
      get :index, params: @default_params
      expect(response).to be_successful
    end
  end
  context 'empty roles' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get :index, params: @default_params
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

end

RSpec.shared_examples 'show action' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns http success' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response).to be_successful
    end
  end
  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get :show, params: @default_params.merge(id: 'obj_test_id')
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end

RSpec.shared_examples 'post action' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'return http success' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'return http success' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'return http success' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'return http success' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'return 403 error' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'return 403 error' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'return 403 error' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token
      end
    end

    it 'return 403 error' do
      post :create, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end

RSpec.shared_examples 'PUT action' do
  before(:each) do
    subject
    @put_action = @action || "update"
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns 403 error' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'no network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end

    it 'return 403 error' do
      put @put_action.to_s, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end

RSpec.shared_examples 'destroy action' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end

    it 'return http success' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end

    it 'return http success' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end

    it 'return http success' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'member' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end

    it 'return http success' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end

    it 'return 403 error' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end

    it 'return 403 error' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end

    it 'return 403 error' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'no network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end

    it 'return 403 error' do
      delete :destroy, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end

RSpec.shared_examples 'GET action with editor context' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
      if @result
        expect(response.body).to eq(@result.to_json)
      end
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
      if @result 
        expect(response.body).to eq(@result.to_json)
      end
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
      if @result 
        expect(response.body).to eq(@result.to_json)
      end
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
      if @result 
        expect(response.body).to eq(@result.to_json)
      end
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end

RSpec.shared_examples 'GET action with viewer context' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end

RSpec.shared_examples 'GET action with cloud_network_admin rule' do
  before(:each) do
    subject
  end

  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to_not be_successful
    end
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to_not be_successful
    end
  end

  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'member' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to_not be_successful
    end
  end

  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

end

RSpec.shared_examples 'GET action with lbaas_admin rule.' do
  before(:each) do
    subject
  end

  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end

  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to_not be_successful
    end
  end

  context 'member' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to_not be_successful
    end
  end

  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end

end

RSpec.shared_examples 'GET action with editor context including loadbalancer_poolmemberadmin' do
  before(:each) do
    subject
  end

  context 'network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'loadbalancer_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'cloud_network_admin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'cloud_network_admin' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'member' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'member' }
        token
      end
    end
    it 'returns http success' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'network_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'network_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_viewer' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_viewer' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
  context 'loadbalancer_poolmemberadmin' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token['roles'] << { 'id' => 'lbaas2_role', 'name' => 'loadbalancer_poolmemberadmin' }
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response).to be_successful
    end
  end
  context 'empty network roles' do
    before :each do
      stub_authentication do |token|
        # token['roles'].delete_if { |h| h['id'] == 'lbaas2_role' }
        token['roles'] = []
        token
      end
    end
    it 'returns 403 error' do
      get @path, params: @default_params.merge(@extra_params)
      expect(response.code).to be == ("403")
      expect(response).to_not be_successful
    end
  end
end