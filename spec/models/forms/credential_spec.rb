require 'spec_helper'
require 'models/forms/shared_examples'
require 'fog/openstack/models/identity_v3/project'

RSpec.describe Forms::Credential do
  it_behaves_like "a base object"
  it_behaves_like "a wrapper for", ::Fog::IdentityV3::OpenStack::OsCredential
    
  before :each do 
    @identity = double("identity").as_null_object
    @credential_model = double("credential")
    allow(@credential_model).to receive(:attributes).and_return(id:1, project_id: 2, type: 'ec2', user_id: 3, blob: '{"access": "test", "secret": "test"}')
    allow(@identity).to receive(:find_credential).with(1).and_return(@credential_model)    
  end

  describe "#attributes" do
    before :each do 
      @forms_credential = Forms::Credential.new(@identity,1)  
    end
    
    it "should return a hash" do
      expect(@forms_credential.attributes.is_a?(Hash)).to eq(true)   
    end
    
    it "contains 1 as id" do
      expect(@forms_credential.attributes[:id]).to eq(1)
    end
    
    it "contains 2 as project_id" do
      expect(@forms_credential.attributes[:project_id]).to eq(2)
    end
    
    it "contains 3 as user_id" do
      expect(@forms_credential.attributes[:user_id]).to eq(3)
    end
    
    it "contains 'ec2' as type" do
      expect(@forms_credential.attributes[:type]).to eq('ec2')
    end
    
    it "contains 'blob' as blob" do
      expect(@forms_credential.attributes[:blob]).to eq({"access"=> "test", "secret"=> "test"})
    end
  end
end