require 'spec_helper'

describe FriendlyIdEntry, type: :model do
  before :each do
    allow(Rails.application.config).to receive(:keystone_endpoint).and_return('http://test1.com')
  end
  
  let!(:p1){FriendlyIdEntry.find_or_create_entry('Project', nil, 'p1', 'project 1')}
  let!(:p2){FriendlyIdEntry.find_or_create_entry('Project', nil, 'p2', 'project 2')}
  let!(:p3){FriendlyIdEntry.find_or_create_entry('Project', nil, 'p3', 'project 3')}
  
  let!(:d1){FriendlyIdEntry.find_or_create_entry('Domain', nil, 'd1', 'domain 1')}
  let!(:d2){FriendlyIdEntry.find_or_create_entry('Domain', nil, 'd2', 'domain 2')}

  let!(:p1_3){FriendlyIdEntry.find_or_create_entry( 'Project', 'd1', 'p3', 'project 3')}
  let!(:p1_4){ FriendlyIdEntry.find_or_create_entry('Project', 'd1', 'p4', 'project 4')}
  let!(:p1_5){FriendlyIdEntry.find_or_create_entry( 'Project', 'd1', 'p5', 'project 5')}

  let!(:p2_3){FriendlyIdEntry.find_or_create_entry('Project', 'd2', 'p3', 'project 3')}
  let!(:p2_4){FriendlyIdEntry.find_or_create_entry('Project', 'd2', 'p4', 'project 4')}
  let!(:p2_8){FriendlyIdEntry.find_or_create_entry('Project', 'd2', 'p8', 'project 8')}
  
  it "finds all entries by key" do
    expect(FriendlyIdEntry.where(key:'p3').count).to eq(3)
  end

  it "finds all entries by class_name and key" do
    expect(FriendlyIdEntry.where(class_name: 'Project', key:'p3').count).to eq(3)
  end

  it "finds all entries by class_name, scope and friendly_key" do
    expect(FriendlyIdEntry.where(class_name: 'Project', scope: 'd1').friendly.find('project-3')).to eq(p1_3)
  end

  it "finds all entries by class_name, scope and key" do
    expect(FriendlyIdEntry.where(class_name: 'Project', scope: 'd1', key: 'p3').first).to eq(p1_3)
  end
  
  describe '::find_or_create_entry' do
    it "returns an existing entry" do
      expect(FriendlyIdEntry.find_or_create_entry('Project','d1','p3','project 3')).to eq(p1_3)
    end
    
    context 'an entry with the same name but different url exists already' do
      let!(:test_entry){ FriendlyIdEntry.create(class_name: 'Project', scope: 'test-domain', key: 'test-project', endpoint: 'http://test2.com', name: 'test') }

      it "should replace this entry" do
        expect {
          expect_any_instance_of(ActiveRecord::Relation).to receive(:delete_all).and_call_original
          expect(FriendlyIdEntry).to receive(:create).with(class_name: 'Project', scope: 'test-domain', name: 'test', key: 'test-project', endpoint: 'http://test1.com').and_call_original
          
          entry = FriendlyIdEntry.find_or_create_entry('Project', 'test-domain', 'test-project', 'test')
          expect(entry.endpoint).to eql('http://test1.com')
        }.to change{FriendlyIdEntry.count}.by(0)  
      end
    end
    
    context 'an entry with the same name and same url exists already' do
      let!(:test_entry){ FriendlyIdEntry.create(class_name: 'Project', scope: 'test-domain', key: 'test-project', endpoint: 'http://test1.com', name: 'test') }

      it "should replace this entry" do
        expect {
          expect_any_instance_of(ActiveRecord::Relation).not_to receive(:delete_all)
          expect(FriendlyIdEntry).not_to receive(:create)
          
          entry = FriendlyIdEntry.find_or_create_entry('Project', 'test-domain', 'test-project', 'test')
          expect(entry.endpoint).to eql('http://test1.com')
        }.to change{FriendlyIdEntry.count}.by(0)  
      end
    end
    
    context 'an entry with the same name and same url but different key exists already' do
      let!(:test_entry){ FriendlyIdEntry.create(class_name: 'Project', scope: 'test-domain', key: 'test-project', endpoint: 'http://test1.com', name: 'test') }

      it "should replace this entry" do
        expect {
          expect(FriendlyIdEntry).to receive(:create).with(class_name: 'Project', scope: 'test-domain', name: 'test', key: 'test-project2', endpoint: 'http://test1.com').and_call_original
          
          entry = FriendlyIdEntry.find_or_create_entry('Project', 'test-domain', 'test-project2', 'test')
          expect(entry.endpoint).to eql('http://test1.com')
        }.to change{FriendlyIdEntry.count}.by(1)  
      end
    end
  end
  


end
