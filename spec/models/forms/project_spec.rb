require 'spec_helper'
require 'models/forms/shared_examples'
require 'fog/openstack/models/identity_v3/project'

RSpec.describe Forms::Project do
  it_behaves_like "a base object"
  it_behaves_like "a wrapper for", ::Fog::IdentityV3::OpenStack::Project
    
  before :each do 
    @identity = double("identity").as_null_object
    @project_model = double("project")
    allow(@project_model).to receive(:attributes).and_return(id:1, name: 'test', description: 'test')
    allow(@identity).to receive(:find_project).with(1).and_return(@project_model)    
  end

  describe "#attributes" do
    before :each do 
      @forms_project = Forms::Project.new(@identity,1)  
    end
    
    it "should return a hash" do
      expect(@forms_project.attributes.is_a?(Hash)).to eq(true)   
    end
    
    it "contains 1 as id" do
      expect(@forms_project.attributes[:id]).to eq(1)
    end
    
    it "contains 'test' as name" do
      expect(@forms_project.attributes[:name]).to eq('test')
    end
    
    it "contains 'test' as description" do
      expect(@forms_project.attributes[:description]).to eq('test')
    end
  end
end