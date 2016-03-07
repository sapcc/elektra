require 'spec_helper'

RSpec.describe Dashboard::RescopingService do
  before :each do 
    @service_user = double("service_user").as_null_object
  end

  describe 'domain_friendly_id' do
    before :each do
      FriendlyIdEntry.delete_all
    end

    context 'entry exists' do
      let!(:key) {'1234-5678'}
      let!(:entry) { FriendlyIdEntry.find_or_create_entry('Domain', nil, key, 'Test Domain') }

      it "should find entry by key" do
        expect(Dashboard::RescopingService.new(nil).domain_friendly_id(key)).to eq(entry)
      end

      it "should find entry by friendly_id" do
        expect(Dashboard::RescopingService.new(nil).domain_friendly_id('test-domain')).to eq(entry)
      end
    end

    context 'entry does not exists' do
      before :each do
        allow(@service_user).to receive(:domain_id).and_return('12-34')
        allow(@service_user).to receive(:domain_name).and_return('test_domain')
      end

      it "should create a new entry by id" do
        expect{
          Dashboard::RescopingService.new(@service_user).domain_friendly_id('12-34')
        }.to change{FriendlyIdEntry.count}.by(1)
      end

      it "should create a new entry by name" do
        expect{
          Dashboard::RescopingService.new(@service_user).domain_friendly_id('test domain')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
    end
  end

  describe 'project_friendly_id' do
    let!(:domain_id){'d1'}

    before :each do
      FriendlyIdEntry.delete_all
      allow(@service_user).to receive(:find_project_by_name_or_id).with('12')
        .and_return(Identity::Project.new(nil,{"id"=>'12',"name"=>'Project 1'}))
    end

    context 'entry exists' do

      let!(:key) {'1234-5678'}
      let!(:entry) { FriendlyIdEntry.find_or_create_entry('Project', domain_id, key, 'Project 1') }


      it "should find entry by key" do
        expect(Dashboard::RescopingService.new(@service_user).project_friendly_id(domain_id,key)).to eq(entry)
      end

      it "should find entry by friendly_id" do
        expect(Dashboard::RescopingService.new(@service_user).project_friendly_id(domain_id, 'project-1')).to eq(entry)
      end
    end

    context 'entry does not exists' do
      it "should create a new entry by id" do
        expect{
          Dashboard::RescopingService.new(@service_user).project_friendly_id(domain_id,'12')
        }.to change{FriendlyIdEntry.count}.by(1)
      end

      it "should create a new entry by name" do
        allow(@service_user).to receive(:find_project_by_name_or_id).and_return(Identity::Project.new(nil,{"id"=>'12',"name"=>'Project 1'}))

        expect{
          Dashboard::RescopingService.new(@service_user).project_friendly_id(domain_id,'Project 1')
        }.to change{FriendlyIdEntry.count}.by(1)
      end
    end
  end
end
