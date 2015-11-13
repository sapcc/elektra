require 'spec_helper'

RSpec.describe ServiceLayer::AdminIdentityService do

  before :each do
    @current_user = double('current_user').as_null_object
    allow(@current_user).to receive(:user_domain_id).and_return(1)
    allow(@current_user).to receive(:id).and_return(1)
    allow(@current_user).to receive(:full_name).and_return("test_user")
    allow(@current_user).to receive(:name).and_return("test")
        
    @driver = double('driver').as_null_object
    @roles = [{"id"=>1,"name"=>"admin"},{"id"=>2,"name"=>"member"}]
    @sandboxes = [{"id"=>1,"name"=>"sandboxes"}]
    @user_sandbox = {"id"=>2}
    
    allow(@driver).to receive(:roles).and_return(@roles)
    allow(@driver).to receive(:projects).with(name:"#{@current_user.name}_sandbox",domain_id: anything).and_return([])
    allow(@driver).to receive(:projects).with(name: 'sandboxes', domain_id: anything).and_return(@sandboxes)
    allow(@driver).to receive(:create_project).with(name:"#{@current_user.name}_sandbox", domain_id: anything, description: anything, enabled:true,parent_id:1).and_return(@user_sandbox)
        
    allow_any_instance_of(ServiceLayer::AdminIdentityService).to receive(:driver).and_return(@driver)
    
    @admin_identity = ServiceLayer::AdminIdentityService.new('http://localhost:5000/v3','europe',@current_user)
  end

  describe 'domain_friendly_id' do
    before :each do
      FriendlyIdEntry.delete_all
    end
      
    context 'entry exists' do
      let!(:key) {'1234-5678'}
      let!(:entry) { FriendlyIdEntry.create(class_name:'Domain',key: key, name: 'Test Domain') }
    
      
      it "should find entry by key" do
        expect(@admin_identity.domain_friendly_id(key)).to eq(entry)
      end  
    
      it "should find entry by friendly_id" do
        expect(@admin_identity.domain_friendly_id('test-domain')).to eq(entry)
      end 
    end
    
    context 'entry does not exists' do
      it "should create a new entry by id" do
        allow(@driver).to receive(:get_domain).with('12-34').and_return({"id"=>'12-34',"name"=>'test domain'})
        
        expect{ 
          @admin_identity.domain_friendly_id('12-34')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
      
      it "should create a new entry by name" do
        allow(@driver).to receive(:get_domain).and_raise('error')
        allow(@driver).to receive(:domains).with(name:'test domain').and_return([{"id"=>'12-34',"name"=>'test domain'}])
        expect{ 
          @admin_identity.domain_friendly_id('test domain')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
    end
  end
  
  describe 'project_friendly_id' do
    let!(:domain_id){'d1'}
    
    before :each do
      FriendlyIdEntry.delete_all
    end
      
    context 'entry exists' do
      
      let!(:key) {'1234-5678'}
      let!(:entry) { FriendlyIdEntry.create(class_name:'Project', scope: domain_id, key: key, name: 'Project 1') }
    
      
      it "should find entry by key" do
        expect(@admin_identity.project_friendly_id(domain_id,key)).to eq(entry)
      end  
    
      it "should find entry by friendly_id" do
        expect(@admin_identity.project_friendly_id(domain_id, 'project-1')).to eq(entry)
      end 
    end
    
    context 'entry does not exists' do
      it "should create a new entry by id" do
        allow(@driver).to receive(:get_project).with('12').and_return({"id"=>'12',"name"=>'Project 1'})
        
        expect{ 
          @admin_identity.domain_friendly_id('12')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
      
      it "should create a new entry by name" do
        allow(@driver).to receive(:get_project).and_raise('error')
        allow(@driver).to receive(:projects).with(domain_id: domain_id, name: 'Project 1').and_return([{"id"=>'12',"name"=>'Project 1'}])
        expect{
          @admin_identity.project_friendly_id(domain_id,'Project 1')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
    end
  end
  
  describe 'create_user_domain_role' do
    it 'should grant a domain role to user' do
      member_role_id = @roles.find{|r| r['name']=='member'}["id"]
      expect(@driver).to receive(:grant_domain_user_role).with(@current_user.user_domain_id,@current_user.id,member_role_id)
      @admin_identity.create_user_domain_role(@current_user,'member')
    end
  end
  
  describe 'create_user_sandbox' do
    it "should return sandbox id" do
      expect(@admin_identity.create_user_sandbox(2,@current_user)).to eq(@user_sandbox["id"])
    end
  end
  
end