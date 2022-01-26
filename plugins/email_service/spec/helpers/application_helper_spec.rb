require "spec_helper"
require_relative '../factories/factories'

RSpec.describe EmailService::ApplicationHelper, :type => :helper do

  before :each do
    @creds = ::EmailService::FakeFactory.new.aws_creds_array
    @creds_err = ::EmailService::FakeFactory.new.aws_creds_error
  end

  describe "#ec2_creds" do 
    it "#check_ec2_data" do 
      expect(@creds.class).to eq(Array)
      expect(@creds_err[:error]).to eq("Error occured")
    end

  end

end