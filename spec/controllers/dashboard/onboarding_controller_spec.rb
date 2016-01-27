require 'spec_helper'

RSpec.describe Dashboard::OnboardingController, type: :controller do

=begin
  include AuthenticationStub

  before(:all) do
    @domain_default_friendly_id = FriendlyIdEntry.find_or_create_entry('Domain',nil,'o-sap_default','sap_default')
    @domain_abc_friendly_id = FriendlyIdEntry.find_or_create_entry('Domain',nil,'o-abc','abc')
  end

  before :each do
    stub_admin_services
  end

  context "whatever" do

    describe "GET 'new_user'" do


      it "returns http success" do

        stub_authentication do |token|
          # no role user
          token["roles"] = {}
          token["domain"] = {"id"=>"#{@domain_default_friendly_id.key}", "name"=>"#{@domain_default_friendly_id.name}"}
        end

        get :new_user, domain_id: @domain_default_friendly_id.slug
        expect(response).to be_success
      end
    end
  end
=end


end
