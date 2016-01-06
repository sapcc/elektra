require 'spec_helper'

RSpec.describe Admin::RescopingService do

  describe 'domain_friendly_id' do
    before :each do
      FriendlyIdEntry.delete_all
    end
      
    context 'entry exists' do
      let!(:key) {'1234-5678'}
      let!(:entry) { FriendlyIdEntry.find_or_create_entry('Domain', nil, key, 'Test Domain') }
      
      it "should find entry by key" do
        expect(Admin::RescopingService.domain_friendly_id(key)).to eq(entry)
      end  
    
      it "should find entry by friendly_id" do
        expect(Admin::RescopingService.domain_friendly_id('test-domain')).to eq(entry)
      end 
    end
    
    context 'entry does not exists' do
      it "should create a new entry by id" do
        allow(Admin::IdentityService).to receive(:find_domain).with('12-34')
          .and_return(Identity::Domain.new(nil,{"id"=>'12-34',"name"=>'test domain'}))
        
        expect{ 
          Admin::RescopingService.domain_friendly_id('12-34')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
      
      it "should create a new entry by name" do
        allow(Admin::IdentityService).to receive(:find_domain).and_raise('error')
        allow(Admin::IdentityService).to receive(:domains).with(name:'test domain')
          .and_return([Identity::Domain.new(nil,{"id"=>'12-34',"name"=>'test domain'})])
        
        expect{
          Admin::RescopingService.domain_friendly_id('test domain')
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
      let!(:entry) { FriendlyIdEntry.find_or_create_entry('Project', domain_id, key, 'Project 1') }


      it "should find entry by key" do
        expect(Admin::RescopingService.project_friendly_id(domain_id,key)).to eq(entry)
      end

      it "should find entry by friendly_id" do
        expect(Admin::RescopingService.project_friendly_id(domain_id, 'project-1')).to eq(entry)
      end
    end

    context 'entry does not exists' do
      it "should create a new entry by id" do
        allow(Admin::IdentityService).to receive(:find_project).with('12')
          .and_return(Identity::Project.new(nil,{"id"=>'12',"name"=>'Project 1'}))

        expect{
          Admin::RescopingService.project_friendly_id(domain_id,'12')
        }.to change{FriendlyIdEntry.count}.by(1)
      end

      it "should create a new entry by name" do
        allow(Admin::IdentityService).to receive(:find_project).and_raise('error')
        allow(Admin::IdentityService).to receive(:projects).with(domain_id: domain_id, name: 'Project 1')
          .and_return([Identity::Project.new(nil,{"id"=>'12',"name"=>'Project 1'})])
          
        expect{
          Admin::RescopingService.project_friendly_id(domain_id,'Project 1')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
    end
  end
end