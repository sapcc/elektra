require 'spec_helper'

describe FriendlyIdEntry, type: :model do
  let!(:p1){FriendlyIdEntry.where(class_name: 'Project', key:'p1').first_or_create(name: 'project 1')}
  let!(:p2){FriendlyIdEntry.where(class_name: 'Project', key:'p2').first_or_create(name: 'project 2')}
  let!(:p3){FriendlyIdEntry.where(class_name: 'Project', key:'p3').first_or_create(name: 'project 3')}
  
  let!(:d1){FriendlyIdEntry.where(class_name: 'Domain',  key:'d1').first_or_create(name: 'domain 1')}
  let!(:d2){FriendlyIdEntry.where(class_name: 'Domain',  key:'d2').first_or_create(name: 'domain 2')}

  let!(:p1_3){FriendlyIdEntry.where(class_name: 'Project', key:'p3', scope: 'd1').first_or_create(name: 'project 3')}
  let!(:p1_4){ FriendlyIdEntry.where(class_name: 'Project', key:'p4', scope: 'd1').first_or_create(name: 'project 4')}
  let!(:p1_5){FriendlyIdEntry.where(class_name: 'Project', key:'p5', scope: 'd1').first_or_create(name: 'project 5')}

  let!(:p2_3){FriendlyIdEntry.where(class_name: 'Project', key:'p3', scope: 'd2').first_or_create(name: 'project 3')}
  let!(:p2_4){FriendlyIdEntry.where(class_name: 'Project', key:'p4', scope: 'd2').first_or_create(name: 'project 4')}
  let!(:p2_8){FriendlyIdEntry.where(class_name: 'Project', key:'p8', scope: 'd2').first_or_create(name: 'project 8')}
  
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
