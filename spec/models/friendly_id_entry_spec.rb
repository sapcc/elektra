require 'spec_helper'

describe FriendlyIdEntry, type: :model do

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
  end

end
