require 'spec_helper'

RSpec.describe Dashboard::OnboardingController, type: :controller do

  include AuthenticationStub
  
  before(:all) do
    @domain_default_friendly_id = FriendlyIdEntry.find_or_create_entry('Domain', nil, 'o-sap_default', Rails.configuration.default_domain)
    @domain_abc_friendly_id = FriendlyIdEntry.find_or_create_entry('Domain', nil, 'o-abc', 'abc')
  end

  before :each do
    stub_admin_services do |service_user|
      allow(service_user).to receive(:list_scope_admins).and_return([Hashie::Mash.new({id: '***REMOVED***', email: 'torsten.lesmann@sap.com', full_name: "Torsten Lesmann"})])
    end
  end

  context "onboarding flow" do

    describe "GET 'onboarding'" do

      it "onboards without inquiry for default domain" do
        stub_authentication do |token|
          # no role user
          token["roles"] = {}
          token["domain"] = {"id" => "#{@domain_default_friendly_id.key}", "name" => "#{@domain_default_friendly_id.name}"}
        end

        get :onboarding, domain_id: @domain_default_friendly_id.slug
        expect(response).to be_success
        expect(response).to render_template(:onboarding_without_inquiry)

        post :register_without_inquiry, {domain_id: @domain_default_friendly_id.slug, terms_of_use: true}
        expect(response).to redirect_to "/#{@domain_default_friendly_id.name}/identity/home"

      end

      it "onboards with inquiry for NON default domain" do
        stub_authentication do |token|
          # no role user
          token["roles"] = {}
          token["domain"] = {"id" => "#{@domain_abc_friendly_id.key}", "name" => "#{@domain_abc_friendly_id.name}"}
        end

        get :onboarding, domain_id: @domain_abc_friendly_id.slug
        expect(response).to be_success
        expect(response).to render_template(:onboarding_with_inquiry)


        post :register_with_inquiry, {domain_id: @domain_default_friendly_id.slug, terms_of_use: true}
        expect(response).to render_template(:onboarding_open_message)

      end
    end

  end

end
